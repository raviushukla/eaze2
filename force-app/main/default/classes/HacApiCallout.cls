public class HacApiCallout {
    
    @AuraEnabled
    public static responseWrapper sendApplication(String recordId){
        Lead leadObj = [Select Id, Social_Security_Number__c, FirstName, LastName, Date_of_Birth__c, MobilePhone, Email, Income_Source_1__c,
                        Current_Employer__c, Street, City, State, PostalCode, Time_at_Address_In_Months__c, Current_Residence_Status__c,
                        Annual_Pre_Tax_Income__c, Monthly_Rent_Mortgage_Amount__c, Loan_Amount__c, Purpose__c, Years_With_Employer__c, Employment_Date__c,
                        Account__r.HAC_Branch_Number__c
                        From Lead Where Id=: recordId];

        Date recidenceDate = Date.today().addMonths(Integer.valueOf(leadObj.Time_at_Address_In_Months__c * -1));
        //Integer empMonths = 1;
        //Date employmentDate = Date.today().addMonths(empMonths * -1);
        
        String employed = '', selfEmployed = '', residenceStatus = '', 
               incomeSource = '', otherIncomeSource = '', otherIncValue = '',
               income =  String.valueOf((leadObj.Annual_Pre_Tax_Income__c/12).setScale(2)); 
        if(leadObj.Income_Source_1__c == 'Employed'){
            employed = 'Yes';
            selfEmployed = 'No';
        }else if(leadObj.Income_Source_1__c == 'Self_Employed'){
            employed = 'No';
            selfEmployed = 'Yes';
        }else{
            employed = 'No';
            selfEmployed = 'No';
            if(leadObj.Income_Source_1__c == 'retired' || leadObj.Income_Source_1__c == 'Retirement Benefits'){
                incomeSource = 'RETIRED';
            }else{
                incomeSource = 'OTHER';
                otherIncomeSource = leadObj.Income_Source_1__c;
            }
            otherIncValue = String.valueOf((leadObj.Annual_Pre_Tax_Income__c/12).setScale(2));
            //income = '';
        }
        
        
        if(leadObj.Current_Residence_Status__c == 'Own' || leadObj.Current_Residence_Status__c == 'Own_Outright' || 
           leadObj.Current_Residence_Status__c == 'Own_with_Mortgage'){
            residenceStatus = 'O';
        }else{
            residenceStatus = 'R';
        }
        
        
        
        String endPoint = Label.HAC_Endpoint;
        String xmlData = '<hac>'+
            '<t>'+ Label.Coaching_Api_Token +'</t>'+
            '<ssno>'+ leadObj.Social_Security_Number__c +'</ssno>'+
            '<branchNo>'+ leadObj.Account__r.HAC_Branch_Number__c +'</branchNo>'+
            '<fName>'+ leadObj.FirstName+ '</fName>'+
            '<lName>'+ leadObj.LastName+ '</lName>'+
            '<dob>'+ String.valueOf(leadObj.Date_of_Birth__c.format()) +'</dob>'+
            '<phoneNo>'+ leadObj.MobilePhone.replaceAll('[^0-9]','')+ '</phoneNo>'+
            '<email>'+ leadObj.Email +'</email>'+
            '<selfEmploy>'+ selfEmployed +'</selfEmploy>'+
            '<employed>'+ employed +'</employed>'+
            '<incSource>'+ incomeSource +'</incSource>'+
            '<employer>'+ leadObj.Current_Employer__c +'</employer>'+
            '<otherIncSource>'+ otherIncomeSource +'</otherIncSource>'+
            '<employDate>'+ String.valueOf(leadObj.Employment_Date__c.format()) +'</employDate>'+
            '<salary>'+ income +'</salary>'+
            '<otherInc>'+ otherIncValue +'</otherInc>'+
            '<otherIncDesc>'+ otherIncomeSource +'</otherIncDesc>'+
            '<stNo>'+ leadObj.Street.left(10) +'</stNo>'+
            '<stName>'+ leadObj.Street +'</stName>'+
            '<city>'+ leadObj.City +'</city>'+
            '<state>'+ leadObj.State +'</state>'+
            '<zip>'+ leadObj.PostalCode +'</zip>'+
            '<addrDate>'+ String.valueOf(recidenceDate.format()) +'</addrDate>'+
            '<resType>'+ residenceStatus +'</resType>'+
            '<mortgage>'+ String.valueOf(leadObj.Monthly_Rent_Mortgage_Amount__c) +'</mortgage>'+
            '<addCoApplicant>No</addCoApplicant>'+
            '<product>'+ leadObj.Purpose__c +'</product>'+	
            '<totPurch>'+ String.valueOf(leadObj.Loan_Amount__c) +'</totPurch>'+
            '<downPymt>0.00</downPymt>'+
            '</hac>';
        
        endPoint += EncodingUtil.urlEncode(xmlData, 'UTF-8');
        String endPointApi = endPoint+xmlData;
        system.debug(endPointApi);
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/x-www-form-urlencoded');
        headerMap.put('Content-Length','0');
        HttpResponse response = RESTCalloutHelper.makeCallout('POST', '', endPoint, headerMap);
        
        String apiEndPoint = endPoint + xmlData;
        API_Log__c logObj = new API_Log__c(Parent_Record__c = recordId, Request_Body__c = apiEndPoint, 
                                           Request_Type__c = 'POST', Type__c = 'Outbound', Source_Destination__c = 'HAC API');
        
        Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response.getbody());
        //system.debug(parsed.get('status'));
        responseWrapper wrapperObj = new responseWrapper(String.valueOf(parsed.get('status')), String.valueOf(parsed.get('desription')));
        
        if(response.getStatusCode() == 200){
            logObj.Response_Body__c = response.getbody();
            logObj.Request_Status__c = String.valueOf(response.getStatusCode());
            leadObj.HAC_Reference_Number__c = String.valueOf(parsed.get('referenceNo'));
            leadObj.HAC_Application_Error__c = String.valueOf(parsed.get('desription'));
        }else{
            logObj.Response_Body__c = response.getbody();
            logObj.Request_Status__c = String.valueOf(response.getStatusCode());
            logObj.Error__c = String.valueOf(parsed.get('desription'));
            leadObj.HAC_Application_Error__c = String.valueOf(parsed.get('desription'));
        }
        
        insert logObj;
        update leadObj; // Updating the HAC reference no. and the error message.
        system.debug(wrapperObj);
        return wrapperObj;
    }
    
    public class responseWrapper{
        
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String description{get;set;}
        public responseWrapper(String status, String description){
            this.status = status;
            this.description = description;
        }
    }
}