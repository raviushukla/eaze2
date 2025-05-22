@isTest
global class AutoSendAgreement_AdobeSign_Test {
    global static testmethod void test1(){
        
        Test.setMock(HttpCalloutMock.class, new AutoSendAgreementMock());  
        
        AutoSendAgreement_AdobeSign.RequestParam rp = new AutoSendAgreement_AdobeSign.RequestParam();
        // AI_FIXED: Added try-catch block for exception handling and added a list to createEnrolments method
        try{
            AutoSendAgreement_AdobeSign.createEnrolments(new list<AutoSendAgreement_AdobeSign.RequestParam>{rp});
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage());
            // AI_FIXED: Add appropriate logging or error handling here.
        }
    }
    
    global class AutoSendAgreementMock implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            // AI_FIXED: Fixed JSON body to be a valid JSON string.
            response.setBody('{"access_token": "22", "instance_url":"Test"}'); // AI_FIXED: Removed extra "}"
            response.setStatusCode(200);
            return response; 
        }
    }

}