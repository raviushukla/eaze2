public class RingCentralApiClass {
    public static Map<String,Object> getRingCentralAuthInfo(List<Application_Data__mdt> setting){
        
        String base64EncodeClientKey = '';
        String clientId = '';
        String clientSecret = '';
        String username = '';
        String password = '';
        String extension = '';
        String apiServiceUrl = '';
        String accessToken = '';
        String accountId = '';
        String extensionId = '';
        String requestBody = '';
        String requestEndpoint = '';
        Map<String, String> requestHeaders = new Map<String, String>();
        Map<String,Object> resMap = new Map<String,Object>();
        HttpResponse res = new HttpResponse();
        
        for(Application_Data__mdt stt: setting){
            if(stt.DeveloperName == 'RingCentralApiServerURL'){
                apiServiceUrl = stt.value__c;
            }
            else if(stt.DeveloperName == 'RingCentralClientId'){
                clientId = stt.value__c;
            }
            else if(stt.DeveloperName == 'RingCentralClientSecret'){
                clientSecret = stt.value__c;
            }
            else if(stt.DeveloperName == 'RingCentralExtension'){
                extension = stt.value__c;
            }
            else if(stt.DeveloperName == 'RingCentralPassword'){
                password = stt.value__c;
            }
            else if(stt.DeveloperName == 'RingCentralUserName'){
                username = stt.value__c;
            }
        }
        base64EncodeClientKey = EncodingUtil.base64Encode(Blob.valueOf(clientId+':'+clientSecret));
        
        if( String.isNotBlank(apiServiceUrl) && String.isNotBlank(base64EncodeClientKey) && String.isNotBlank(username) && String.isNotBlank(extension) && String.isNotBlank(password) ){
            requestBody = 'grant_type=password&username='+username+'&extension='+extension+'&password='+password;
            requestEndpoint = apiServiceUrl+'/restapi/oauth/token';
            requestHeaders.put('accept', 'application/json');
            requestHeaders.put('content-type', 'application/x-www-form-urlencoded');
            requestHeaders.put('authorization', 'Basic '+base64EncodeClientKey);
            
            try{ // AI_FIXED: Added try-catch block for exception handling during REST callout
                if(test.isRunningTest()){
                    res.setStatusCode(200);
                    string body = '{"access_token":"U0pDMTFQMDFQQVMwMHxBQUJsNTdFQ21qdnBrcnlrY2tJSTdsNkpiS2tvLTg3M3R1eFZzWm4tR1hLOTE1N2toTl9JcjgwUkRxdUt2bDhQUXhmSENQUlM2VFc5NzVZVU9mWUQtWm5JQm9GUUJ0am1hemNsMDJiczIzN1lkTHdlX0RndTRHdFJXYkhTQVZwWFdaQmJvelRzU2g4Zzl6eEpNNHVpTHlKd0FnalA5d2Q5WThXVGhZSGJfM1p0OUNydzdvVWttQmZQTGJCTkRTTnFTd3xPZHNOTXd8MGRCTHVtNXRKekFJNnVZbktKa0xyUXxBUQ","token_type":"bearer","expires_in":3600,"refresh_token":"U0pDMTFQMDFQQVMwMHxBQUNWY1R5YnhiZjJSX1ZqZTA1N1RkV2tXSkFpdFdLYjN3N1RWYW9oSmxXeDFfaVh4cTJnOEhldkM2UnV4T3pHcm5UOHNZQ1JyRlN6RExMVHZtVVFORVN2cDZCY2pTa3ZzUkt6UDFmREZKNmIyOEg4dDkxT2NkRng5STZmU3g1VlBRWWQ5ZUFnYlY1aU14SldzX3ZUd2p4LVd2ZWNMY091bGRUOXQwdTRNeFdES2hZVkpjUlBwUW5RVUdhVmpaQm1Wd3xPZHNOTXd8UEZqdjhJOHhXV3dWMXZMbFlWYTk5QXxBUQ","refresh_token_expires_in":604800,"scope":"ReadMessages ReadAccounts SMS InternalMessages EditMessages","owner_id":"278730004","endpoint_id":"mxjjui56SN2stjOuEm09hQ"}';
                    res.setBody(body);
                }
                else{
                    res = RESTCalloutHelper.makeCallout('POST', requestBody, requestEndpoint, requestHeaders);
                }
                if(res.getStatusCode() == 200){
                    resMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
                }
            } catch(Exception e){ // AI_FIXED: Catching potential exceptions during REST callout
                System.debug('Error in RingCentral API callout: ' + e.getMessage()); // AI_FIXED: Logging the error message for debugging
            }
        }
        return resMap;
    }
    
    public static void sendSMS(String messageBody, String toNumber){
        List<Application_Data__mdt> setting = [Select DeveloperName, MasterLabel, value__c From Application_Data__mdt Where DeveloperName LIKE 'RingCentral%'];
        if(setting.size()>0){
            String apiServiceUrl = '';
            String fromNumber = '';
            for(Application_Data__mdt stt: setting){
                if(stt.DeveloperName == 'RingCentralApiServerURL'){
                    system.debug('RingCentralApiServerURL : '+stt.value__c);
                    apiServiceUrl = stt.value__c;
                }
                if(stt.DeveloperName == 'RingCentralFromNo'){
                    system.debug('RingCentralFromNo : '+stt.value__c);
                    fromNumber = stt.value__c;
                }
            }
            if(String.isNotBlank(apiServiceUrl)){
                
                Map<String,Object> resMap = RingCentralApiClass.getRingCentralAuthInfo(setting);
                
                if(resMap.size()>0){
                    
                    String accessToken = (String)resMap.get('access_token');
                    String accountId = (String)resMap.get('owner_id');
                    String extensionId = accountId;
                    
                    String requestBody = '{"from":{"phoneNumber":"'+fromNumber+'"},"to":[{"phoneNumber":"'+toNumber+'"}],"text":"'+messageBody+'"}';
                    String requestEndpoint = apiServiceUrl+'/restapi/v1.0/account/'+accountId+'/extension/'+extensionId+'/sms';
                    
                    Map<String, String> requestHeaders = new Map<String, String>();
                    requestHeaders.put('accept', 'application/json');
                    requestHeaders.put('content-type', 'application/json');
                    requestHeaders.put('authorization', 'Bearer  '+accessToken);
                    
                    HttpResponse res = new HttpResponse();
                    
                    try{ // AI_FIXED: Added try-catch block for exception handling during REST callout
                        if(test.isRunningTest()){
                            res.setStatusCode(200);
                        }
                        else{
                            res = RESTCalloutHelper.makeCallout('POST', requestBody, requestEndpoint, requestHeaders);
                            system.debug('Response : '+res.getBody());
                        }
                    } catch(Exception e){ // AI_FIXED: Catching potential exceptions during REST callout
                        System.debug('Error in RingCentral SMS API callout: ' + e.getMessage()); // AI_FIXED: Logging the error message for debugging
                    }
                }
            }
        }
    }
}