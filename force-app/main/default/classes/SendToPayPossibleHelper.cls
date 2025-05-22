public class SendToPayPossibleHelper {
    
    @InvocableMethod(label='Send To Pay Possible')
    public static void sendLeadToPayPossible( list<id> leads ){
        system.debug('leadsProcessMethod '+leads);
        // AI_FIXED: Changed to process all leads in the list instead of only the first one.  Improved performance and functionality.
        for(Id leadId : leads){
            try{
                PayPossibleHelper.sendLeadToPayPossibleFuture(leadId); // AI_FIXED: Added try-catch block for exception handling.
            } catch(Exception e){
                System.debug('Error processing lead ' + leadId + ': ' + e.getMessage()); // AI_FIXED: Added logging for better error tracking.
                // AI_FIXED: Consider adding more robust error handling, such as storing errors in a custom object or sending email notifications.
            }
        }
    }
    
}