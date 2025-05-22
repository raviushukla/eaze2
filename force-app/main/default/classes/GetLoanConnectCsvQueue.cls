/*
	We made a queueable class to get the data from FTP beacause on Canada Lead Status
	update we are calling a future method
	UMESH RANA
	03/27/2023
	Test Class -> getCanadaLoanConnectCsv_Test
*/

public class GetLoanConnectCsvQueue implements Queueable,Database.AllowsCallouts {
    
    public String fileDate =  '';
    public static Map<String, String> loanConnectAndEazeStatusMap = new Map<String, String>();
    public static Map<String, Integer> eazeStatusSeqMap = new Map<String, Integer>();
    
    public GetLoanConnectCsvQueue(String fileDate){
        this.fileDate = fileDate;
    }
    public void execute(QueueableContext context) {
        try {
            List<String> eazeStatus = Label.LoanConnectStatusMapping.split(',');
            for(String status : eazeStatus){
                List<String> keyValue = status.split('=>');
                loanConnectAndEazeStatusMap.put(keyValue[0],keyValue[1]);
            }
            List<String> eazeStatusSeq = Label.Canada_Status_Sequence.split(',');
            for(String status : eazeStatusSeq){
                List<String> keyValue = status.split('=>');
                eazeStatusSeqMap.put(keyValue[0],Integer.valueOf(keyValue[1]));
            }
            system.debug('eazeStatusSeqMap : '+eazeStatusSeqMap);
            //String fileName = '2022-11-08_CF.csv';
            String fileName = this.fileDate+'_CF.csv';
            String endPoint = 'https://xdkpgtm6gg.execute-api.us-east-1.amazonaws.com/v1/report?fileName='+fileName;
            Map<String, String> header = new Map<String, String>();
            List<String> leadErrorList = new List<String>(); 
            Map<String, String> loanConnectAndEazeStatus = new Map<String, String>();
            Map<String, Lead> leadMap = new Map<String, Lead>();
            Map<String, String> idClientIdMap = new Map<String, String>();
            header.put('x-api-key', Label.loanConnectCsvKey);
            HttpResponse response = RESTCalloutHelper.makeCallout('GET','',endPoint, header);
            system.debug('Responce - > ' + response.getBody() );
            system.debug('Responce - > ' + response.getStatus() );
            system.debug('Responce - > ' + response.getStatusCode() );
            Map<String,String> clientIdStatusMap = new Map<String,String>(); 
            List<String> loanValues = new List<String>();
            Boolean noData = false, error = false, updateError = false;
            
            if( response.getStatusCode() == 200){
                String[] csvFileLines = response.getBody().split('\n');
                system.debug(csvFileLines);
                List<String> cleanedRow = new List<String>();
                system.debug('**** '+ csvFileLines.size());
                for(String row : csvFileLines){                   
                    String connectedFields = '';
                    if( row.contains('"') ){
                        for( String field : row.split('"') ){
                            if( !cleanedRow.contains(row) ){
                                if( field.startsWith(',') || field.endsWith(',') ){
                                    connectedFields += field;
                                }else{
                                    field = field.replace(',',' ');
                                    connectedFields += field;                                
                                }
                            }
                        }
                        cleanedRow.add(connectedFields);
                    }else{
                        cleanedRow.add(row);
                    } 
                }
                system.debug('**** '+ cleanedRow.size());
                List<String> headerList = cleanedRow[0].split(',');
                Integer clientIdIndex = headerList.indexOf('client_id');
                Integer statusIndex = headerList.indexOf('status');    
                if(cleanedRow.size() == 1){
                    noData = true;
                }else{
                    for(Integer i=1; i<cleanedRow.size(); i++ ){
                        loanValues = cleanedRow[i].split(',');
                        if(String.isNotBlank(loanValues[clientIdIndex]) && String.isNotBlank(loanValues[statusIndex])){
                            clientIdStatusMap.put(loanValues[clientIdIndex].replace('\'',''),loanValues[statusIndex]);
                        }
                    }
                } 
                system.debug('**** '+ clientIdStatusMap);
                if(clientIdStatusMap.keySet().size() > 0){
                    List<Lead> leadList = [Select Id, Loan_Connect_Client_Id__c, Status, Loan_Connect_Status_Update_Date__c, ErrorLog__c from Lead Where Loan_Connect_Client_Id__c IN: clientIdStatusMap.keySet() AND Loan_Connect_Client_Id__c != null];
                    List<Lead> leadListUpdate = new List<Lead>();
                    for(Lead leadObj : leadList){
                        leadMap.put(leadObj.Id, leadObj);
                        if(Date.valueOf(fileDate) > leadObj.Loan_Connect_Status_Update_Date__c || leadObj.Loan_Connect_Status_Update_Date__c == null){ // Using this check so that the Lead is updated with the latest date. 
                            system.debug('eazeStatusSeqMap.get(leadObj.Status) :' + eazeStatusSeqMap.get(leadObj.Status) + '   eazeStatusSeqMap.get(loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c).trim())) : '+eazeStatusSeqMap.get(loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c).trim())));
                            if(eazeStatusSeqMap.get(leadObj.Status) < eazeStatusSeqMap.get(loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c).trim())) && loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c)) != null && string.isNotBlank(loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c))) && leadObj.Status != loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c).trim())){
                                leadObj.Status = loanConnectAndEazeStatusMap.get(clientIdStatusMap.get(leadObj.Loan_Connect_Client_Id__c).trim());
                                leadObj.Loan_Connect_Status_Update_Date__c = Date.valueOf(fileDate);
                                leadListUpdate.add(leadObj);
                            }
                        }
                    }
                    
                    Database.SaveResult[] srList;
                    if(leadListUpdate.size() > 0){
                        srList = Database.update(leadListUpdate, false);
                    }
                    List<Lead> leadErrorUpdateList = new List<Lead>(); 
                    if(srList != null){
                        for(Integer i=0; i < srList.size(); i++) {
                            if(srList.get(i).isSuccess()) {
                                System.debug('Records are updated Successfully');
                            } 
                            else if(!srList.get(i).isSuccess()) {
                                Database.Error errors =  srList.get(i).getErrors().get(0);
                                leadErrorList.add('Failure Record Ids While Updating '+srList.get(i).Id+ ' Loan Connect Client Id : '+idClientIdMap.get(srList.get(i).Id) +' Error Occurs While Processing The Record '+errors.getMessage());
                                Lead ldObj = leadMap.get(srList.get(i).Id);
                                ldObj.ErrorLog__c = ldObj.ErrorLog__c == null ? 'Error Occurs While Processing The Record'+errors.getMessage() : ldObj.ErrorLog__c + ' Error Occurs While Processing The Record'+errors.getMessage();
                                leadErrorUpdateList.add(ldObj);
                                
                            }
                        }
                    }
                    if(leadErrorUpdateList.size() > 0){
                        update leadErrorUpdateList;
                    }
                }   
            }else{
                error = true;
            }
            
            API_Log__c apiLogObj = new API_Log__c();
            if(error){
                apiLogObj.Request_Status__c = 'Error' ; 
                apiLogObj.Error__c = response.getStatus() ; 
            }else if(noData){
                apiLogObj.Request_Status__c = 'No Data' ; 
            }else if(updateError){
                apiLogObj.Request_Status__c = 'Update Error'; 
                apiLogObj.Error__c = leadErrorList.toString();
            }else{
                apiLogObj.Request_Status__c = 'Success' ; 
            }
            apiLogObj.Type__c = 'Outbound';
            apiLogObj.Request_Type__c = 'GET';
            apiLogObj.Response_Body__c = response.getBody();
            apiLogObj.Endpoint_URL__c = endPoint;
            apiLogObj.Source_Destination__c = 'Loan Connect FTP';
            INSERT apiLogObj;
        } catch(DmlException e) {
            API_Log__c apiLogObj = new API_Log__c();
            apiLogObj.Request_Status__c = 'Error' ; 
            apiLogObj.Error__c = 'The following exception has occurred: ' + e.getMessage(); 
            apiLogObj.Type__c = 'Outbound';
            apiLogObj.Request_Type__c = 'GET';
            apiLogObj.Endpoint_URL__c = 'https://xdkpgtm6gg.execute-api.us-east-1.amazonaws.com/v1/report?fileName='+fileDate+'_CF.csv';
            apiLogObj.Source_Destination__c = 'Loan Connect FTP';
            INSERT apiLogObj;
        }   
    }
}