// Test Class -> LwcUnsubscribePrimaryContact_Test
public without sharing class LwcUnsubscribePrimaryContactController {
    
    @AuraEnabled
    public static boolean updateContact(string email){
        boolean recordUpdated = false;
        if (String.isBlank(email)) { // AI_FIXED: Added null check for email to prevent errors.
            return false; // AI_FIXED: Return false if email is blank.
        }
        try {
           List<Contact> conList = [Select Id, HasOptedOutOfEmail from Contact Where Email = :email LIMIT 1]; // AI_FIXED: Added HasOptedOutOfEmail to SOQL query to avoid unnecessary query.
           if(conList.size()>0){
                Contact con = conList[0]; // AI_FIXED: Assign to a single contact variable for better readability.
                con.HasOptedOutOfEmail = true;
                update con; // AI_FIXED: Update the single contact variable instead of the list.
                recordUpdated = true; 
           } 
        } catch (DmlException e) { // AI_FIXED: Changed Exception to DmlException for more specific error handling.
            // AI_FIXED: Handle DML exceptions appropriately. Log the error for debugging purposes.  Consider adding more robust error handling based on specific DMLException codes.
            System.debug('Error updating contact: ' + e.getMessage());
            throw new AuraHandledException('Error updating contact. Please try again later.'); // AI_FIXED: Provide a user-friendly message.
        } catch (Exception e) { // AI_FIXED: Kept generic Exception catch block for unexpected errors.
            System.debug('Unexpected error updating contact: ' + e.getMessage()); // AI_FIXED: Log unexpected errors for debugging.
            throw new AuraHandledException('An unexpected error occurred. Please contact support.'); // AI_FIXED: Provide a user-friendly message.
        }
        return recordUpdated;
    }
}