public class SendToPayPossible {
	@AuraEnabled
    public static string LeadToPayPossible(String leadId){
        return PayPossibleWebServiceClass.sendLeadToPayPossible(leadId);
    }
}