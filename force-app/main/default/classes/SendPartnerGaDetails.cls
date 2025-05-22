//	Sending "Welcome Call Done - Ready To Fund" Status Emails to the clients
//	Test Class - SendPartnerGaDetails_Test
//	Lighting Cmp - SendPartnerGaDetails
public class SendPartnerGaDetails {
	
    @AuraEnabled
    public static void sendEmail(String recordId){
        Guaranteed_Approval_Application__c gaObj = [Select Id, Account__r.Primary_Contact__c, Account__c, Corporate_Business_Name__c from Guaranteed_Approval_Application__c Where Id =: recordId];
        List<EmailTemplate> templateList = [Select Id, Name, DeveloperName from EmailTemplate Where DeveloperName IN ('GA_Welcome_Call_Done_Ready_To_Fund_Email' ,'GA_48_Hr_After_Welcome_Call','Portal_Login_Instructions_for_GA_Only') ORDER By CreatedDate ASC];
        String orgWideAddressId = [select id, Address, DisplayName from OrgWideEmailAddress].Id;
        List<Messaging.SingleEmailMessage> emailListFirst = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> emailListSecond = new List<Messaging.SingleEmailMessage>();
        for(EmailTemplate obj : templateList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(gaObj.Account__r.Primary_Contact__c);
            email.setTemplateId(obj.Id);
            email.setWhatId(gaObj.Id);
            email.setOrgWideEmailAddressId(orgWideAddressId);
            email.setSaveAsActivity(false);
            if(obj.DeveloperName == 'GA_Welcome_Call_Done_Ready_To_Fund_Email'){
            	emailListFirst.add(email);
            }else{
                emailListSecond.add(email);
            }
        }
        
        String jobName = 'After 24hr 3th Notification ' + gaObj.Corporate_Business_Name__c;
        After24HrsGaEmailSchedule schObj = new After24HrsGaEmailSchedule();
        schObj.recordId = recordId;
        DateTime now = DateTime.now();
        DateTime executionDatetime = now.addHours(24);
        for (CronTrigger ct : [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE CronJobDetail.Name = :jobName]) {
            System.abortJob(ct.Id);
        }
        Messaging.SendEmailResult[] emailResultsFirst = Messaging.sendEmail(emailListFirst);
        if (emailResultsFirst[0].isSuccess()) {
            Messaging.SendEmailResult[] emailResultsSecond = Messaging.sendEmail(emailListSecond);
            System.schedule(jobName, '0 ' + executionDatetime.minute() + ' ' + executionDatetime.hour() + ' ' + executionDatetime.day() + ' ' + executionDatetime.month() + ' ? ' + executionDatetime.year(), schObj);
            System.debug('Email sent successfully');
        } else {
            System.debug('Failed to send the email: ' + emailResultsFirst[0].getErrors()[0].getMessage());
        }

    }
}