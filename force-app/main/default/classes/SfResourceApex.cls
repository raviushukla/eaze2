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
        String leadId = apexpages.currentpage().getparameters().get('leadId');
        Lead leadObj = [Select Id, Account__c, Agent_Name__c, Name__c, Agent_Name_Text__c, MobilePhone, Agent_Name__r.Recourse_Notification__c, Agent_Name__r.Email From Lead Where Id =: leadId];
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
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Notifications sent successfully'));
        } catch(DmlException e) {
            System.debug('The following exception has occurred: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The following exception has occurred: ' + e.getMessage()));
        }
    }
    
    
    
    /*
	String leadId = apexpages.currentpage().getparameters().get('leadId');
        Lead leadObj = [Select Id, Name__c, Agent_Name__c, Secondary_Agent_Email__c, Tertiary_Agent_Email__c, MobilePhone, Email From Lead Where Id =:leadId];
        List<EmailTemplate> emailTemplateList = [Select Id, Name from EmailTemplate where Name = 'SF Resource Applicant Notification'];
        String applicantEmailTemp = '';
        for(EmailTemplate tempObj : emailTemplateList){
            if(tempObj.Name == 'SF Resource Applicant Notification'){
                applicantEmailTemp = tempObj.Id;
            }
        }
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage emailApplicant = new Messaging.SingleEmailMessage();
        emailApplicant.setTargetObjectId(leadObj.id); 
        emailApplicant.setSaveAsActivity(true); 
        emailApplicant.setTemplateID(applicantEmailTemp); 
        //message.setWhatId(account.Id); //This is important for the merge fields in template to work
        emailApplicant.toAddresses = new String[] { leadObj.Email};
        emailList.add(emailApplicant);    
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        
        if (results[0].success) 
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Notifications sent successfully'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The following exception has occurred: ' + results[0].errors[0].message));
        }
*/
}