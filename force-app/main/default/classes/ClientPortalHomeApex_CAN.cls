public without sharing class ClientPortalHomeApex_CAN {
    @AuraEnabled
    public static User fetchUserInfo(){
        return [Select Name, ContactId, Contact.Name, Contact.Account.Name, UserType, Profile.Name From User Where Id =: UserInfo.getUserId()];
    }
    @AuraEnabled
    public static object sessionCheck(String sessionId){
        system.debug('sessionId'+sessionId);
        List<Login_Session__c>  ls = [SELECT Contact__r.Name, Contact__r.Account.Name, Contact__r.Account.Portal_Access__c, 
                                      Contact__r.Account.Agreement_Status_Canada__c, Contact__r.Account.Logo_URL__c, Contact__r.Account.Funding_Script__c, 
                                      Contact__r.Account.Telegram_Link_Formula__c, Contact__r.Account.Main_Canada_Application_Link__c, Contact__r.Account.Team_Tracking_Link__c
                                      From Login_Session__c 
                                      Where Session_Id__c = :sessionId
                                      AND Type__c = 'User Login'
                                      AND Expired__c =: false Limit 1];
        system.debug('ls'+ls);
        //allowelse login
        if(ls.size()==1){
            return ls[0];
        }
        return null;
    }
    @AuraEnabled
    public static Account fetchAccInfo(String recordId){
        return [Select Name,  Portal_Access__c,Logo_URL__c,Agreement_Status_Canada__c, Telegram_Link_Formula__c, 
                Main_Canada_Application_Link__c, Team_Tracking_Link__c,Funding_Script__c 
                From Account Where Id =: recordId Limit 1];
    }
    
    
}