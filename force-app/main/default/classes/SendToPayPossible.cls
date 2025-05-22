public class SendToPayPossible {
	@AuraEnabled
    public static string LeadToPayPossible(String leadId){
        String result = ''; // AI_FIXED: Initialized result string to avoid null pointer exception
        try {
            // AI_FIXED: Added null check for leadId to prevent errors
            if (String.isBlank(leadId)) {
                result = 'Lead ID cannot be empty'; // AI_FIXED: Handle empty leadId case
            } else {
                result = PayPossibleWebServiceClass.sendLeadToPayPossible(leadId);
            }
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to catch and log errors
            result = 'Error processing lead: ' + e.getMessage(); // AI_FIXED: Provide a user-friendly error message
            System.debug('Error in LeadToPayPossible: ' + e.getMessage() + ' Stack Trace: ' + e.getStackTraceString()); // AI_FIXED: Log the error for debugging purposes
        }
        return result;
    }
}