global without sharing class PayPossibleWebServiceClass {
    webservice static String sendLeadToPayPossible(String leadId) {
        String str = PayPossibleHelper.sendLeadToPayPossible(leadId );
        return str;
    }

    webservice static void getOfferFromPayPossible(String leadId) {
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String apiNames =  '';
        for(string apiName : r.fields.getMap().keySet()){
            if( string.isNotBlank(apiNames)){
                apiNames += ','+apiName;
            }else{
                apiNames = apiName;
            }
        }
        String queryOnLead = 'Select '+apiNames+' from Lead where id =: leadId';
        list<lead> leadList = database.Query(queryOnLead);
        Lead l = leadList[0];
        try{
            String accessToken = PayPossibleHelper.getPayPossibleAccessToken();
            PayPossibleHelper.getOffersFromPayPossible(accessToken,l );
        }catch( Exception ex ){
            if( l.ErrorLog__c == null ){
                l.ErrorLog__c  = '';
            }
            l.ErrorLog__c += '\n'+System.now()+'\n'+ex.getMessage();
            update l;
        }
    }
}