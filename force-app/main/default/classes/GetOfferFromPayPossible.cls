public class GetOfferFromPayPossible {
	@AuraEnabled
    public static string offerFromPayPossible(String leadId){
        String result = '';
        try{
            // AI_FIXED: Added null check for leadId to prevent NullPointerException
            if (leadId == null) {
                return 'Error: Lead ID cannot be null';
            }
            // AI_FIXED:  Calling the external web service method and handling potential exceptions.  The original code was missing error handling for the external call.
            try {
                result = PayPossibleWebServiceClass.getOfferFromPayPossible(leadId);
            } catch (Exception ex) {
                // AI_FIXED: More informative error message including the original exception.
                return 'Error calling PayPossibleWebServiceClass: ' + ex.getMessage();
            }
            
            // AI_FIXED: Check for null or empty result from the web service.
            if (result == null || result.isEmpty()) {
                return 'Error: No offer found from PayPossibleWebServiceClass';
            }
            
            result = 'Success'; // AI_FIXED: Moved success message assignment after successful web service call.
        }
        catch(Exception ex){
            // AI_FIXED: Improved error message for better debugging.
            return 'An unexpected error occurred: ' + ex.getMessage();
        }
        return result;
    }
}