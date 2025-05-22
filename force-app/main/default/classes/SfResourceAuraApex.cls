public with sharing class SfResourceAuraApex {
    @AuraEnabled
    public static boolean sendNotifications(String recordId){
        boolean result = false;
        Lead leadObj = [Select Id, Account__c, Agent_Name__c, Name__c, Agent_Name_Text__c, MobilePhone, Agent_Name__r.Recourse_Notification__c, Agent_Name__r.Email From Lead Where Id =: recordId];
        List<String> recourseAgentEmails = leadObj.Agent_Name__r.Recourse_Notification__c != null ? leadObj.Agent_Name__r.Recourse_Notification__c.split(',') : new List<String>{leadObj.Agent_Name__r.Email};
        List<EmailTemplate> emailTemplateList = [Select Id, Name from EmailTemplate where Name = 'SF Resource Agent Notification'];
        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=: Label.SfResourceOEA];
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage emailAgent = new Messaging.SingleEmailMessage();
        emailAgent.setTargetObjectId(leadObj.id); 
        emailAgent.setSaveAsActivity(true); 
        emailAgent.setTemplateID(emailTemplateList[0].Id); 
        emailAgent.toAddresses = recourseAgentEmails;
        emailAgent.setOrgWideEmailAddressId(owea.Id);
        emailList.add(emailAgent);    
        
        Map<String, Object> recordIdMap = new Map<String, Object>();
        recordIdMap.put('leadObj', leadObj);
        Flow.Interview.SF_Resource_Notifications notificationFlow = new Flow.Interview.SF_Resource_Notifications(recordIdMap);
        
        try {
            notificationFlow.start();
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            result = true;
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
        }
        
        return result;
    }
}