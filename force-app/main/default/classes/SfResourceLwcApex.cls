public with sharing class SfResourceLwcApex {
    
    @AuraEnabled
    public static boolean sendNotifications(String recordId){
        boolean result = false;
        Lead leadObj = null;
        try{
            leadObj = [Select Id, Account__c, Agent_Name__c, Name__c, Agent_Name_Text__c, MobilePhone, Agent_Name__r.Recourse_Notification__c, Agent_Name__r.Email From Lead Where Id =: recordId]; // AI_FIXED: Added try-catch block to handle query exceptions
        } catch(Exception e){
            System.debug('Error querying Lead record: ' + e.getMessage());
            return false; // AI_FIXED: Return false if query fails
        }

        List<String> recourseAgentEmails = new List<String>();
        if(leadObj != null && leadObj.Agent_Name__r != null){ // AI_FIXED: Added null checks to prevent NullPointerExceptions
            String recourseNotification = leadObj.Agent_Name__r.Recourse_Notification__c;
            recourseAgentEmails = (recourseNotification != null) ? recourseNotification.split(',') : new List<String>{leadObj.Agent_Name__r.Email};
        }

        List<EmailTemplate> emailTemplateList = [Select Id, Name from EmailTemplate where Name = 'SF Resource Agent Notification'];
        if(emailTemplateList.isEmpty()){
            System.debug('Email template not found.'); // AI_FIXED: Added logging for missing email template
            return false; // AI_FIXED: Return false if email template is not found
        }

        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=: Label.SfResourceOEA];
        if(owea == null){
            System.debug('Org-wide email address not found.'); // AI_FIXED: Added logging for missing org-wide email address
            return false; // AI_FIXED: Return false if org-wide email address is not found
        }

        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage emailAgent = new Messaging.SingleEmailMessage();
        if(leadObj != null){ // AI_FIXED: Added null check to prevent NullPointerException
            emailAgent.setTargetObjectId(leadObj.id); 
        }
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
        } catch(Exception e) { // AI_FIXED: Changed exception type to Exception for broader handling
            System.debug('The following exception has occurred: ' + e.getMessage()); // AI_FIXED: Improved logging message
            result = false; // AI_FIXED: Set result to false on exception
        }
        
        return result;
    }
}