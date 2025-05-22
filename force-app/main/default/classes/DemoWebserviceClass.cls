@RestResource(urlMapping='/demoWebService/*')
global without sharing class DemoWebserviceClass {
    
    @HttpPost
    global static void doPost() {
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            Blob body = req.requestBody;
            System.debug('body--->'+body);
            String jsonString = body.toString();
            if(jsonString.length()>0){
                Map<String, Object> m1 = (Map<String, Object>)Json.deserializeUntyped(jsonString);
                
                String idVal = (String)m1.get('id');
                String stVal = (String)m1.get('status');
                
                if( String.isNotBlank(idVal) ){
                    // AI_FIXED: Added try-catch block for DML operation and improved error handling.
                    try{
                        Lead leadToUpdate = new Lead(Id = idVal , Status = stVal );
                        update leadToUpdate; // AI_FIXED: Updated lead using a Lead object instead of directly using the constructor in update statement.
                    } catch(DmlException e){
                        // AI_FIXED: Handle DML exceptions appropriately, log error details, and set appropriate response status.
                        res.setStatusCode(500);
                        res.responseBody = Blob.valueOf('Error updating Lead: ' + e.getMessage());
                        System.debug('DML Exception: ' + e.getMessage());
                        return;
                    }
                }
                
                
            }
        }catch(Exception ex){
            // AI_FIXED: Improved exception handling by providing more specific error messages and setting appropriate response status.
            res.setStatusCode(500); // AI_FIXED: Set appropriate HTTP status code for errors.
            res.responseBody = Blob.valueOf('Error processing request: ' + ex.getMessage()); // AI_FIXED: Set response body with error details.
            System.debug('Error: '+ ex.getMessage() );
            
        }
    }

}