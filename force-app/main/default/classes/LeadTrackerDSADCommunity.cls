public class LeadTrackerDSADCommunity {
    @AuraEnabled
    public static String fetchUserInfo() {
        return userInfo.getUserType();
    }
}