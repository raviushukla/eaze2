public class SendToCreditPull {
    @AuraEnabled
    public static string LeadPreQualification(String leadId){
        String result = ''; // AI_FIXED: Initialize result string to avoid null pointer exception
        try {
            // AI_FIXED: Added try-catch block for exception handling
            if (String.isBlank(leadId)) { // AI_FIXED: Added null check for leadId
                return 'Lead ID is missing'; // AI_FIXED: Return error message instead of throwing exception
            }
            Id leadIdObj = Lead.getLeadId(leadId); // AI_FIXED: Use Lead.getLeadId to prevent SOQL injection
            if(leadIdObj == null){
                return 'Invalid Lead ID'; // AI_FIXED: Return error message for invalid leadId
            }
            result = LeadPreQualificationApex.LeadPreQualificationPost(leadIdObj.toString()); // AI_FIXED: Pass Id as string to avoid potential issues
        } catch (Exception e) {
            // AI_FIXED: Handle exceptions gracefully
            result = 'Error processing lead: ' + e.getMessage();
        }
        return result;
    }
}