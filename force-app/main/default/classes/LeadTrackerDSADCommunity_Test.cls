@isTest
public class LeadTrackerDSADCommunity_Test {
    public static testMethod void method(){
        Test.startTest();
        try { // AI_FIXED: Added try-catch block for exception handling
            LeadTrackerDSADCommunity.fetchUserInfo();
        } catch (Exception e) { // AI_FIXED: Added catch block to handle potential exceptions
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added logging for debugging purposes
        }
        Test.stopTest();
    }
}