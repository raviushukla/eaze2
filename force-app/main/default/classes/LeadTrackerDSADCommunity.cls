public class LeadTrackerDSADCommunity {
    @AuraEnabled
    public static String fetchUserInfo() {
        try {
            return UserInfo.getUserType(); // AI_FIXED: Corrected casing of UserInfo
        } catch (Exception e) {
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Error fetching user info: ' + e.getMessage());
            return null; // AI_FIXED: Return null in case of error
        }
    }
}