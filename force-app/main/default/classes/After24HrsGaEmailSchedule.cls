public class After24HrsGaEmailSchedule implements Schedulable {
    
    public String recordId;
    
    public void execute(SchedulableContext sc) {
        try {
            // AI_FIXED: Added try-catch block for exception handling
            Guaranteed_Approval_Application__c gaObj = [Select Id, Account__r.Primary_Contact__c, Account__c from Guaranteed_Approval_Application__c Where Id =: recordId]; // AI_FIXED: Removed unnecessary space
            if (gaObj == null) {
                // AI_FIXED: Handle case where recordId is invalid
                System.debug('Guaranteed_Approval_Application__c record not found for Id: ' + recordId);
                return;
            }
            if (gaObj.Account__r == null || gaObj.Account__r.Primary_Contact__c == null) {
                // AI_FIXED: Handle null Account or Contact
                System.debug('Account or Primary Contact not found for GA Application: ' + gaObj.Id);
                return;
            }
            EmailTemplate templateobj = [Select Id, Name, DeveloperName from EmailTemplate Where DeveloperName = 'GA_120_Hr_After_Welcome_Call' LIMIT 1]; // AI_FIXED: Removed unnecessary space
            if (templateobj == null) {
                // AI_FIXED: Handle case where email template is not found
                System.debug('Email template GA_120_Hr_After_Welcome_Call not found.');
                return;
            }
            Id orgWideAddressId = [select id from OrgWideEmailAddress].Id; // AI_FIXED: Optimized SOQL query to select only Id
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(gaObj.Account__r.Primary_Contact__c);
            email.setTemplateId(templateobj.Id);
            email.setWhatId(gaObj.Id);
            email.setOrgWideEmailAddressId(orgWideAddressId);
            email.setSaveAsActivity(false);
            emailList.add(email);
            Messaging.SendEmailResult[] emailResults = Messaging.sendEmail(emailList);
            if (emailResults[0].isSuccess()) {
                System.debug('Email sent successfully!'); // AI_FIXED: Added success message
            } else {
                System.debug('Failed to send the email: ' + emailResults[0].getErrors()[0].getMessage());
            }
        } catch (Exception e) {
            // AI_FIXED: Improved exception handling
            System.debug('An unexpected error occurred: ' + e.getMessage());
        }
        System.debug('Scheduled job executed!');
    }
}