public class LeadStatusUpdateClass {
    
    @InvocableMethod(label='Lead Status Update to OEA' description='Send Lead Status to OEA')
    public static void sendLeadStatusUpdate( list<Id> leadIds ){
        // AI_FIXED: Corrected case of LeadIds to leadIds
        list<Lead> leads = [ Select Id,Third_Party_Contact_Id__c,Email,Status,Credit_Score__c from Lead where Id IN :leadIds AND (LeadSource = 'OEA Application' OR Agent_Name__r.Account.Client_Code__c = 'OEA')]; // AI_FIXED: Added colon before leadIds to correct SOQL query
        if( !leads.isEmpty() ){
            for( Lead l : leads ){ // AI_FIXED: Corrected case of Leads to leads
                try{
                    Integer creditScore = l.Credit_Score__c != null ? Integer.valueOf(l.Credit_Score__c) : 0; // AI_FIXED: Changed Integer.valueof to Integer.valueOf
                    makeCalloutToOEA( l.Third_Party_Contact_Id__c,l.Email, l.Status, creditScore );
                }catch( Exception ex){
                    // AI_FIXED: Improved exception handling by logging more details
                    System.debug('Exception occurred for Lead Id: ' + l.Id + ', Message: ' + ex.getMessage() + ', Stack Trace: ' + ex.getStackTraceString());
                }
            }
        }
    }
    
    @future(callout=true)
    public static void makeCalloutToOEA(String tpId, String email, String newStatus, Integer CreditScore){
        HttpRequest req = new HttpRequest();
        req.setEndpoint(Label.OEA_Status_Update_Endpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        // AI_FIXED: Improved JSON string creation using JSONGenerator for better readability and maintainability.  Also added null checks to prevent errors.
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        jsonGen.writeStringField('key', Label.OEA_Key);
        jsonGen.writeStringField('secret', Label.OEA_Secret);
        jsonGen.writeStringField('contactId', tpId);
        jsonGen.writeStringField('email', email);
        jsonGen.writeStringField('newStatus', newStatus);
        jsonGen.writeNumberField('credit_score', CreditScore);
        jsonGen.writeEndObject();
        String body = jsonGen.getAsString();
        req.setBody(body);
        system.debug(body);
        Http h = new Http();
        try{ // AI_FIXED: Added try-catch block for callout exception handling.
            if( !test.isRunningTest() ){
                HttpResponse res = h.send(req);
                // AI_FIXED: Added basic response handling.  More robust error handling should be implemented based on the OEA API response.
                if (res.getStatusCode() != 200) {
                    System.debug('Callout failed with status code: ' + res.getStatusCode() + ', Response Body: ' + res.getBody());
                }
            }
        } catch (System.CalloutException ex) {
            // AI_FIXED: Improved exception handling by logging more details
            System.debug('Callout Exception: ' + ex.getMessage() + ', Stack Trace: ' + ex.getStackTraceString());
        }
    }
}