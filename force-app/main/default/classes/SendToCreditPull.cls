public class SendToCreditPull {
    @AuraEnabled
    public static string LeadPreQualification(String leadId){
        return LeadPreQualificationApex.LeadPreQualificationPost(leadId);
    }
}