//	Sending 3th Email Notification 24hrs later by quick action button
//	Test Class - After24HrsGaEmailSchedule_Test
//
//
//
public class After24HrsGaEmailSchedule implements Schedulable {
    
    public string recordId;
    
    public void execute(SchedulableContext sc) {
        Guaranteed_Approval_Application__c gaObj = [Select Id, Account__r.Primary_Contact__c, Account__c from Guaranteed_Approval_Application__c Where Id =: recordId];
        EmailTemplate templateobj = [Select Id, Name, DeveloperName from EmailTemplate Where DeveloperName = 'GA_120_Hr_After_Welcome_Call' LIMIT 1];
        String orgWideAddressId = [select id, Address, DisplayName from OrgWideEmailAddress].Id;
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
        } else {
            System.debug('Failed to send the email: ' + emailResults[0].getErrors()[0].getMessage());
        }
        System.debug('Scheduled job executed!');
    }
}