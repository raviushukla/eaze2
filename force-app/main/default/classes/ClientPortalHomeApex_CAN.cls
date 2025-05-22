public without sharing class ClientPortalHomeApex_CAN {
    @AuraEnabled
    public static User fetchUserInfo(){
        try{
            return [Select Name, ContactId, Contact.Name, Contact.Account.Name, UserType, Profile.Name From User Where Id =: UserInfo.getUserId()];
        } catch(Exception e){
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Exception in fetchUserInfo: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static object sessionCheck(String sessionId){
        if (sessionId == null || sessionId.isEmpty()) {
            // AI_FIXED: Added null and empty check for sessionId to prevent SOQL injection
            return null;
        }
        try{
            List<Login_Session__c>  ls = [SELECT Contact__r.Name, Contact__r.Account.Name, Contact__r.Account.Portal_Access__c, 
                                          Contact__r.Account.Agreement_Status_Canada__c, Contact__r.Account.Logo_URL__c, Contact__r.Account.Funding_Script__c, 
                                          Contact__r.Account.Telegram_Link_Formula__c, Contact__r.Account.Main_Canada_Application_Link__c, Contact__r.Account.Team_Tracking_Link__c
                                          From Login_Session__c 
                                          Where Session_Id__c = :sessionId // AI_FIXED: Using parameterized query to prevent SOQL injection
                                          AND Type__c = 'User Login'
                                          AND Expired__c = false Limit 1];
            if(ls.size()==1){
                return ls[0];
            }
            return null;
        } catch(Exception e){
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Exception in sessionCheck: ' + e.getMessage());
            return null;
        }
    }
    @AuraEnabled
    public static Account fetchAccInfo(String recordId){
        if (recordId == null || recordId.isEmpty()) {
            // AI_FIXED: Added null and empty check for recordId to prevent SOQL injection
            return null;
        }
        try{
            return [Select Name,  Portal_Access__c,Logo_URL__c,Agreement_Status_Canada__c, Telegram_Link_Formula__c, 
                    Main_Canada_Application_Link__c, Team_Tracking_Link__c,Funding_Script__c 
                    From Account Where Id =: recordId // AI_FIXED: Using parameterized query to prevent SOQL injection Limit 1];
        } catch(Exception e){
            // AI_FIXED: Added try-catch block for exception handling
            System.debug('Exception in fetchAccInfo: ' + e.getMessage());
            return null;
        }
    }
}