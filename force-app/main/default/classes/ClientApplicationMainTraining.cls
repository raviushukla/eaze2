public without sharing class ClientApplicationMainTraining {
    @AuraEnabled
    public static Account getAccDetail(String recordId){
        Account acc = [Select Id, Funding_Script__c, Telegram_Link__c, Agent_Sign_Up_Link__c, GA_Application_Link__c, 
                            Application_Link_New__c, Training_Video__c, Agreement_Status__c, Team_Tracking_Link__c, Eaze_Analytics_Login_Link__c
                            From Account Where Id=: recordId];
        return acc;
    }
}