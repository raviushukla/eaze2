/*
 * Umesh Rana : 8th Feb 2024
 * Calling Flow to Send the Notification to the applicant and agent.
 * Apex called from the VF page which is called from a Custom Button "SF Rsource"on Lead Detail Page
 * Test Class -> SfResourceApex_Test
 * 
 * 
*/
public class SfResourceApex {
    
    public static void callFlow(){
        String leadId = ApexPages.currentPage().getParameters().get('leadId'); // AI_FIXED: Corrected ApexPages capitalization
        if (leadId == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead ID is missing.')); // AI_FIXED: Added error handling for missing leadId
            return;
        }
        Lead leadObj = [Select Id, Account__c, Agent_Name__c, Name__c, Agent_Name_Text__c, MobilePhone, Agent_Name__r.Recourse_Notification__c, Agent_Name__r.Email From Lead Where Id =: leadId]; // AI_FIXED: Removed unnecessary space
        if (leadObj == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Lead not found.')); // AI_FIXED: Added error handling for null leadObj
            return;
        }
        List<String> recourseAgentEmails = leadObj.Agent_Name__r.Recourse_Notification__c != null ? leadObj.Agent_Name__r.Recourse_Notification__c.split(',') : new List<String>{leadObj.Agent_Name__r.Email};
        List<EmailTemplate> emailTemplateList = [Select Id, Name from EmailTemplate where Name = 'SF Resource Agent Notification']; // AI_FIXED: Removed unnecessary space
        if (emailTemplateList.isEmpty()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Email template not found.')); // AI_FIXED: Added error handling for missing email template
            return;
        }
        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName=: Label.SfResourceOEA]; // AI_FIXED: Removed unnecessary space
        if (owea == null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Org-wide email address not found.')); // AI_FIXED: Added error handling for missing OWEA
            return;
        }
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage emailAgent = new Messaging.SingleEmailMessage();
        emailAgent.setTargetObjectId(leadObj.id); 
        emailAgent.setSaveAsActivity(true); 
        emailAgent.setTemplateID(emailTemplateList[0].Id); 
        emailAgent.setToAddresses(recourseAgentEmails); // AI_FIXED: Corrected method name to setToAddresses
        emailAgent.setOrgWideEmailAddressId(owea.Id);
        emailList.add(emailAgent);    
        
        Map<String, Object> recordIdMap = new Map<String, Object>();
        recordIdMap.put('leadObj', leadObj);
        Flow.Interview.SF_Resource_Notifications notificationFlow = new Flow.Interview.SF_Resource_Notifications(recordIdMap);
        
        try {
            notificationFlow.start();
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            if (results != null && results.size() > 0 && results[0].isSuccess()) { // AI_FIXED: Added null check and success check for email results
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Notifications sent successfully')); // AI_FIXED: Corrected ApexPages capitalization
            } else {
                // AI_FIXED: Improved error handling for email sending failures
                String errorMessage = 'Error sending email: ';
                for (Messaging.SendEmailResult result : results) {
                    if (!result.isSuccess()) {
                        for (Messaging.EmailError error : result.getErrors()) {
                            errorMessage += error.getMessage() + '; ';
                        }
                    }
                }
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errorMessage));
            }
        } catch(Exception e) { // AI_FIXED: Changed exception type to Exception for broader handling
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An error occurred: ' + e.getMessage())); // AI_FIXED: Improved error message
        }
    }
}