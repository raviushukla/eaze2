public class SimpleTextingApi {
   	
    @future(callout=true)
    public static void sendSmsAsync(String messageBody, String toNumber, String recordId, String fromNum){
        String msgId = sendSMS(messageBody, toNumber, recordId,fromNum);
        if(!String.isBlank(msgId)){
        	update new Twilio_SMS__c(Id=recordId, Message_Id__c	= msgId);
        }
    }
    
    public static string sendSmsSync(String messageBody, String toNumber, String recordId, String fromNum){
        return sendSMS(messageBody, toNumber, '',fromNum);
    }
    
    public static String sendSMS(String messageBody, String toNumber, String recordId, String fromNum){
        String messageId = '';
        API_Log__c apiLog = new API_Log__c(
            Parent_Record__c = recordId,
            Type__c = 'Outbound',
            Source_Destination__c = 'SimpleTexting',
            Request_Type__c = 'POST',
            Request_Status__c = 'Received'
        );
        try{
            List<Application_Data__mdt> setting = [Select DeveloperName, MasterLabel, value__c From Application_Data__mdt Where DeveloperName LIKE 'SimpleTexting%'];
            if(setting.size()>0){
                String accessToken = '';
                String requestEndpoint = '';
                String requestBody = '';
                String fromNumber = fromNum;
                
                for(Application_Data__mdt stt: setting){
                    if(stt.DeveloperName == 'SimpleTextingApiToken'){
                        system.debug('SimpleTextingApiToken : '+stt.value__c);
                        accessToken = stt.value__c;
                    }
                    if(stt.DeveloperName == 'SimpleTextingApiServerURL'){
                        system.debug('SimpleTextingApiServerURL : '+stt.value__c);
                        requestEndpoint = stt.value__c;
                    }
                    if(stt.DeveloperName == 'SimpleTextingFromNumber' && String.isBlank(fromNumber)){
                        system.debug('SimpleTextingFromNumber : '+stt.value__c);
                        fromNumber = stt.value__c;
                    }
                }
                if(String.isNotBlank(accessToken) && String.isNotBlank(requestEndpoint)){
                    requestEndpoint+='messages';
                    system.debug('requestEndpoint : '+requestEndpoint);
                    apiLog.Endpoint_URL__c = requestEndpoint;
                    
                    requestBody = '{"contactPhone": "'+toNumber+'","accountPhone": "'+fromNumber+'", "mode": "AUTO", "text": "'+messageBody+'"}';
                    
                    Map<String, String> requestHeaders = new Map<String, String>();
                    requestHeaders.put('accept', 'application/json');
                    requestHeaders.put('Authorization', 'Bearer '+accessToken);
                    requestHeaders.put('content-type', 'application/json');
                    

                    HttpResponse res = new HttpResponse();
                    if(test.isRunningTest()){
                        String testBody = '{"id":"6176d88f25ce4e68b97994a9","credits":38}';
                        res.setBody(testBody);
                        res.setStatusCode(201);
                    }
                    else{
                    	res = RESTCalloutHelper.makeCallout('POST', requestBody, requestEndpoint, requestHeaders);
                    }
                    system.debug('Response : '+res.getBody());
                    apiLog.Response_Body__c = res.getBody();
                    if(res.getStatusCode() == 201){
                        Map<String, Object> resBodyMap = (Map<String, Object>)Json.deserializeUntyped(res.getBody());
                        system.debug('resBodyMap---->>'+resBodyMap);
                        messageId = (String)resBodyMap.get('id');
                    }
                }
            }
        }
        catch(exception ex){
            system.debug('Error: '+ ex.getMessage() );
            apiLog.Response_Body__c = ex.getLineNumber()+' : '+ ex.getMessage();
            if(!system.isBatch()){
             	CommonUtil.createAPILog(apiLog);   
            }
        }
        return messageId;
    }
    
}