public class LeadStatusUpdateClass {
    
    @InvocableMethod(label='Lead Status Update to OEA' description='Send Lead Status to OEA')
    public static void sendLeadStatusUpdate( list<Id> leadIds ){
        list<Lead> leads = [ Select Id,Third_Party_Contact_Id__c,Email,Status,Credit_Score__c from Lead where Id IN: LeadIds AND (LeadSource = 'OEA Application' OR Agent_Name__r.Account.Client_Code__c = 'OEA')];
        if( !leads.isEmpty() ){
            for( Lead l : Leads ){
                try{
                    Integer creditScore = l.Credit_Score__c != null ? Integer.valueof(l.Credit_Score__c) : 0;
                    makeCalloutToOEA( l.Third_Party_Contact_Id__c,l.Email, l.Status, creditScore );
                }catch( Exception ex){
                    system.debug('Exeption='+ex.getMessage());
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
        String body = '{'+
                '"key": "'+Label.OEA_Key+'",'+
                '"secret": "'+Label.OEA_Secret+'",'+
                '"contactId": "'+tpId+'",'+
                '"email": "'+email+'",'+
                '"newStatus": "'+newStatus+'",'+
                '"credit_score": '+CreditScore+            
            '}';
        req.setBody(body);
        system.debug(body);
        Http h = new Http();
        if( !test.isRunningTest() ){
            HttpResponse res = h.send(req);
        }
    }
}