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
                    update new lead(Id = idVal , Status = stVal );
                }
                
                
            }
        }catch(Exception ex){
            system.debug('Error: '+ ex.getMessage() );
            
        }
    }

}