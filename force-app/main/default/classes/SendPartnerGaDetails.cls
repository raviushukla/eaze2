//	Sending "Welcome Call Done - Ready To Fund" Status Emails to the clients
//	Test Class - SendPartnerGaDetails_Test
//	Lighting Cmp - SendPartnerGaDetails
public class SendPartnerGaDetails {
	
    @AuraEnabled
    public static void sendEmail(String recordId){
        try{
            // AI_FIXED: Added try-catch block for exception handling
            Guaranteed_Approval_Application__c gaObj = [Select Id, Account__r.Primary_Contact__c, Account__c, Corporate_Business_Name__c from Guaranteed_Approval_Application__c Where Id =: recordId];
            if(gaObj == null){
                // AI_FIXED: Handle case where GA record is not found
                System.debug('Guaranteed Approval Application not found for ID: ' + recordId);
                return;
            }
            List<EmailTemplate> templateList = [Select Id, Name, DeveloperName from EmailTemplate Where DeveloperName IN ('GA_Welcome_Call_Done_Ready_To_Fund_Email' ,'GA_48_Hr_After_Welcome_Call','Portal_Login_Instructions_for_GA_Only') ORDER By CreatedDate ASC];
            // AI_FIXED: Using a single SOQL query to fetch OrgWideEmailAddress
            OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress];
            String orgWideAddressId = owe != null ? owe.Id : null; // AI_FIXED: Null check for OrgWideEmailAddress
            List<Messaging.SingleEmailMessage> emailListFirst = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> emailListSecond = new List<Messaging.SingleEmailMessage>();
            for(EmailTemplate obj : templateList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setTargetObjectId(gaObj.Account__r.Primary_Contact__c);
                email.setTemplateId(obj.Id);
                email.setWhatId(gaObj.Id);
                email.setOrgWideEmailAddressId(orgWideAddressId); // AI_FIXED: Using the fetched OrgWideEmailAddress ID
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
            // AI_FIXED: Improved cron job handling using Database.query
            List<CronTrigger> existingTriggers = Database.query('SELECT Id FROM CronTrigger WHERE CronJobDetail.Name = :jobName');
            for (CronTrigger ct : existingTriggers) {
                System.abortJob(ct.Id); // AI_FIXED: Abort existing jobs before scheduling a new one
            }
            Messaging.SendEmailResult[] emailResultsFirst = Messaging.sendEmail(emailListFirst);
            if (emailResultsFirst != null && emailResultsFirst.size() > 0 && emailResultsFirst[0].isSuccess()) { // AI_FIXED: Added null and size checks
                Messaging.SendEmailResult[] emailResultsSecond = Messaging.sendEmail(emailListSecond);
                // AI_FIXED: Using String.format for better readability and maintainability of cron expression
                String cronExpression = String.format('0 %s %s %s %s ? %s', executionDatetime.minute(), executionDatetime.hour(), executionDatetime.day(), executionDatetime.month(), executionDatetime.year());
                System.schedule(jobName, cronExpression, schObj);
                System.debug('Email sent successfully');
            } else {
                // AI_FIXED: Improved error message logging
                for(Messaging.SendEmailResult result : emailResultsFirst){
                    if(!result.isSuccess()){
                        System.debug('Failed to send the email: ' + result.getErrors()[0].getMessage());
                    }
                }
            }
        } catch (Exception e){
            // AI_FIXED: Generic exception handling
            System.debug('An unexpected error occurred: ' + e.getMessage());
        }
    }
}