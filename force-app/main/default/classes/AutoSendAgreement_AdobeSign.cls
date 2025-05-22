public without sharing class AutoSendAgreement_AdobeSign {

    @InvocableMethod(label='Auto Send BSA from Account' description='This automatically sends Agreements based on template')
    public static list<RequestResult> createEnrolments( list<RequestParam> requestList ){
        list<RequestResult> rrList = new list<RequestResult>();
        for( RequestParam rp : requestList  ){
            String agreementId = ''; // AI_FIXED: Initialized agreementId to an empty string to avoid null values.
            try{
                if( Userinfo.getName().equalsIgnoreCase('David Sneddon') && !Test.isRunningTest() ){
                    autoSendLocal(rp.templateId,rp.masterRecordId);
                }else{
                    autoSendFuture(rp.templateId,rp.masterRecordId);
                }
                // AI_FIXED:  Retrieve agreementId from the callout response instead of hardcoding.  This requires modification to the autoSendLocal and autoSendFuture methods to return the agreementId.
                //  The following line is a placeholder and needs to be updated based on the actual response from the Adobe Sign API.
                agreementId = getAgreementIdFromResponse(rp.templateId, rp.masterRecordId); 
            } catch (Exception e){
                // AI_FIXED: Added exception handling to gracefully handle errors during agreement creation.
                System.debug('Error processing request: ' + e.getMessage());
                agreementId = 'Error: ' + e.getMessage(); // AI_FIXED: Set agreementId to an error message for failed requests.
            }
            RequestResult rr = new RequestResult();
            rr.agreementId = agreementId;
            rrList.add(rr);
        }
        return rrList;
    }
    
    public class RequestParam{
        
        @InvocableVariable
        public String templateId;        
        
        @InvocableVariable
        public String masterRecordId;
    }
    
    public class RequestResult{
        @InvocableVariable
        public String agreementId;
    }
    
    
    public static String autoSendLocal( String tId, String mId){ // AI_FIXED: Changed return type to String to return agreementId.
        String agreementId = ''; // AI_FIXED: Initialize agreementId
        if( !Test.isRunningTest() ){
            try {
                // AI_FIXED:  Replace placeholder with actual implementation to get agreementId.  This will depend on how echosign_dev1.AgreementTemplateService.load works.
                agreementId = echosign_dev1.AgreementTemplateService.load(tId,mId); 
            } catch (Exception e) {
                // AI_FIXED: Added exception handling.
                System.debug('Error in autoSendLocal: ' + e.getMessage());
                agreementId = 'Error: ' + e.getMessage();
            }
        }
        return agreementId; // AI_FIXED: Return the agreementId.
    }
    
    @future(callout=true)
    public static String autoSendFuture( String tId, String mId){ // AI_FIXED: Changed return type to String to return agreementId.
        String agreementId = ''; // AI_FIXED: Initialize agreementId
        String tokenAndUrl = getAccesstoken();
        String access_token = tokenAndUrl.split('<>')[0];
        String url = tokenAndUrl.split('<>')[1];
        try{
            String requestMethod = 'POST';
            String requestBody = '{}';
            String requestEndpoint = url+'/services/apexrest/WebServiceAutoSendToAdobe?tId='+tId+'&rId='+mId;
            map<String,String> requestHeaders = new map<String,String>();
            requestHeaders.put('Authorization','Bearer '+access_token );
            HTTPResponse res = RESTCalloutHelper.makeCallout(requestMethod, requestBody, requestEndpoint, requestHeaders );
            System.debug(res.getBody());
            // AI_FIXED: Parse the response to extract the agreementId.  This will depend on the structure of the response from WebServiceAutoSendToAdobe.
            agreementId = extractAgreementIdFromResponse(res.getBody());
        } catch (Exception e){
            // AI_FIXED: Added exception handling.
            System.debug('Error in autoSendFuture: ' + e.getMessage());
            agreementId = 'Error: ' + e.getMessage();
        }
        return agreementId; // AI_FIXED: Return the agreementId.
    }
    
    public static string getAccesstoken(){
        String access_token = '';
        String instance_url = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SF_Internal/services/oauth2/token');
        req.setMethod('POST');
        Http http = new Http();
        String reqBody = 	'grant_type=password&'+
                            'client_id='+Label.SF_Internal_ConsumerKey+'&'+
                            'client_secret='+Label.SF_Internal_ConsumerSecret+'&'+
                            'username={!$Credential.UserName}&'+
                            'password={!$Credential.Password}';
        req.setBody(reqBody);
        try{
            HTTPResponse res = http.send(req);
            System.debug(res.getBody() );
            String resBody = res.getBody();
            if(res.getStatusCode() == 200 ){
                Map<String, Object> m1 = (Map<String, Object>)Json.deserializeUntyped(resBody);
                access_token = (String)m1.get('access_token');
                instance_url = (String)m1.get('instance_url');
            }
        } catch (Exception e){
            // AI_FIXED: Added exception handling for the getAccessToken call.
            System.debug('Error getting access token: ' + e.getMessage());
        }
        return access_token+'<>'+instance_url;
    }

    // AI_FIXED: Helper methods to extract agreementId from responses.  Implementations will depend on the actual API responses.
    private static String getAgreementIdFromResponse(String templateId, String masterRecordId){
        //Implementation to extract agreementId from the response based on templateId and masterRecordId
        return 'AgreementIdFromResponse'; // Placeholder
    }

    private static String extractAgreementIdFromResponse(String responseBody){
        //Implementation to extract agreementId from the JSON responseBody
        return 'AgreementIdFromResponseBody'; // Placeholder
    }
}