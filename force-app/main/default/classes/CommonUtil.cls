public class CommonUtil {
    
    
    public static API_Log__c createAPILog(API_Log__c apiLog) { // AI_FIXED: Removed unnecessary space in method signature
        try {
            insert apiLog; // AI_FIXED: Wrapped insert statement in try-catch block for exception handling
            return apiLog;
        } catch (DMLException e) {
            // AI_FIXED: Added exception handling for DML errors
            System.debug('Error creating API Log: ' + e.getMessage()); 
            return null; // AI_FIXED: Return null to indicate failure
        } catch (Exception e) {
            // AI_FIXED: Added generic exception handling
            System.debug('Unexpected error creating API Log: ' + e.getMessage());
            return null; // AI_FIXED: Return null to indicate failure
        }
    }

}