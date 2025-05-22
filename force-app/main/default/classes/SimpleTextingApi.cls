public class SimpleTextingApi {
   	
    @future(callout=true)
    public static void sendSmsAsync(String messageBody, String toNumber, String recordId, String fromNum){
        String msgId = sendSMS(messageBody, toNumber, recordId,fromNum);
        if(!String.isBlank(msgId)){
            try{
        	    Twilio_SMS__c smsRecord = new Twilio_SMS__c(Id=recordId, Message_Id__c	= msgId); // AI_FIXED: Created a new Twilio_SMS__c instance to avoid DML operation on null object
                update smsRecord; // AI_FIXED: Updated the code to use the newly created instance
            } catch(DmlException e){
                //Handle DML exception appropriately, e.g., log the error
                System.debug('DML Exception: ' + e.getMessage());
            }
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
            // AI_FIXED: Using a more specific SOQL query to improve performance and avoid potential issues.
            Application_Data__mdt[] settings = [SELECT DeveloperName, MasterLabel, value__c FROM Application_Data__mdt WHERE DeveloperName IN ('SimpleTextingApiToken', 'SimpleTextingApiServerURL', 'SimpleTextingFromNumber')];
            
            String accessToken = '';
            String requestEndpoint = '';
            String fromNumber = fromNum;
                
            for(Application_Data__mdt stt: settings){
                if(stt.DeveloperName == 'SimpleTextingApiToken'){
                    system.debug('SimpleTextingApiToken : '+stt.value__c);
                    accessToken = stt.value__c;
                } else if(stt.DeveloperName == 'SimpleTextingApiServerURL'){
                    system.debug('SimpleTextingApiServerURL : '+stt.value__c);
                    requestEndpoint = stt.value__c;
                } else if(stt.DeveloperName == 'SimpleTextingFromNumber' && String.isBlank(fromNumber)){
                    system.debug('SimpleTextingFromNumber : '+stt.value__c);
                    fromNumber = stt.value__c;
                }
            }
            // AI_FIXED: Added null checks for accessToken and requestEndpoint to prevent NullPointerException
            if(String.isNotBlank(accessToken) && String.isNotBlank(requestEndpoint)){
                requestEndpoint+='messages';
                system.debug('requestEndpoint : '+requestEndpoint);
                apiLog.Endpoint_URL__c = requestEndpoint;
                
                // AI_FIXED: Using JSONGenerator for better performance and readability when constructing JSON
                JSONGenerator jsonGen = JSON.createGenerator(true);
                jsonGen.writeStartObject();
                jsonGen.writeStringField('contactPhone', toNumber);
                jsonGen.writeStringField('accountPhone', fromNumber);
                jsonGen.writeStringField('mode', 'AUTO');
                jsonGen.writeStringField('text', messageBody);
                jsonGen.writeEndObject();
                String requestBody = jsonGen.getAsString();

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
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception to catch all possible exceptions
            System.debug('Error: '+ ex.getMessage() );
            apiLog.Response_Body__c = ex.getLineNumber()+' : '+ ex.getMessage();
            apiLog.Request_Status__c = 'Error'; // AI_FIXED: Update API Log status to reflect the error
            if(!system.isBatch()){
                CommonUtil.createAPILog(apiLog);   
            }
        }
        finally{
            // AI_FIXED: Added a finally block to ensure the API log is created even if an exception occurs.
            if(system.isBatch()){
                CommonUtil.createAPILog(apiLog);
            }
        }
        return messageId;
    }
    
}