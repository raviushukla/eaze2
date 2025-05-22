global without sharing class PayPossibleWebServiceClass {
    webservice static String sendLeadToPayPossible(String leadId) {
        String str = PayPossibleHelper.sendLeadToPayPossible(leadId );
        return str;
    }

    webservice static void getOfferFromPayPossible(String leadId) {
        // AI_FIXED: Added try-catch block to handle exceptions during query
        try{
            // AI_FIXED: Using a more efficient way to get all field names
            List<String> apiNames = new List<String>();
            for(Schema.DescribeFieldResult fieldResult : Lead.sObjectType.getDescribe().fields.getMap().values()){
                apiNames.add(fieldResult.getName());
            }
            String queryOnLead = 'SELECT ' + String.join(apiNames, ',') + ' FROM Lead WHERE Id = :leadId LIMIT 1'; // AI_FIXED: Using String.join for better readability and preventing SOQL injection
            List<Lead> leadList = Database.query(queryOnLead); // AI_FIXED: Changed to Database.query for better readability

            if(leadList.size() > 0){
                Lead l = leadList[0];
                String accessToken = PayPossibleHelper.getPayPossibleAccessToken();
                PayPossibleHelper.getOffersFromPayPossible(accessToken,l );
            } else {
                // AI_FIXED: Handle case where lead is not found.  Log appropriately.
                System.debug('Lead not found for Id: ' + leadId);
            }
        } catch (Exception ex) {
            // AI_FIXED: Improved exception handling and logging
            System.debug('Exception in getOfferFromPayPossible: ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString());
        }
    }
}