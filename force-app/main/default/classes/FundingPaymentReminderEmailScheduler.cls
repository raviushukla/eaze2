/* Schedule Apex to run every 10 minutes
System.schedule('Funding Payment Reminder Emails 1', '0 0 * * * ?', new FundingPaymentReminderEmailScheduler());
System.schedule('Funding Payment Reminder Emails 2', '0 10 * * * ?', new FundingPaymentReminderEmailScheduler());
System.schedule('Funding Payment Reminder Emails 3', '0 20 * * * ?', new FundingPaymentReminderEmailScheduler());
System.schedule('Funding Payment Reminder Emails 4', '0 30 * * * ?', new FundingPaymentReminderEmailScheduler());
System.schedule('Funding Payment Reminder Emails 5', '0 40 * * * ?', new FundingPaymentReminderEmailScheduler());
System.schedule('Funding Payment Reminder Emails 6', '0 50 * * * ?', new FundingPaymentReminderEmailScheduler());
*/
global class FundingPaymentReminderEmailScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        DateTime tempDate = system.now().addMinutes(-5);
        List<Lead> leadList = [Select Name, Email, Payment_Link__c, Immediate_Payment_Reminder_Sent__c 
                               From Lead 
                               Where Intro_Done_DateTime__c <=: tempDate 
                               AND Status != 'Setup Fee Paid To EAZE' 
                               AND LeadSource = 'Funding Partner Intro Done'
                               AND IsConverted = false
                               AND Immediate_Payment_Reminder_Sent__c = false
                              ];
        if(leadList.size()>0){
            sendResetLink(leadList);
        }
    }
    global void sendResetLink(List<Lead> leadList){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        List<EmailMessage> EmailMessageList = new List<EmailMessage>();
        for(Lead ld: leadList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(ld.id); 
            email.setSenderDisplayName('Eaze Support'); 
            email.setReplyTo('support@eazeconsulting.com');
            email.setUseSignature(false); 
            email.setBccSender(false); 
            email.setSaveAsActivity(false); 
            EmailTemplate emailTemplate = [Select Body From EmailTemplate Where DeveloperName =: Label.Funding_Payment_Email_Template];
            email.setTemplateID(emailTemplate.Id); 
            email.toAddresses = new List<String>{ ld.email };
                List<String> ccAddresses = Label.Funding_Payment_CcAddresses.split(',');
            email.setCcAddresses(ccAddresses);
            emailList.add(email);
            ld.Immediate_Payment_Reminder_Sent__c = true;
            ld.Status = 'Setup Fee - Invoice Sent';
            String body = emailTemplate.Body;
            if(ld.Name != null)
            	body = body.replace('{!Lead.Name}', ld.Name);
            if(ld.Payment_Link__c != null)
                body = body.replace('{!Lead.Payment_Link__c}', ld.Payment_Link__c);
            EmailMessage emailMessage = new EmailMessage();
            emailMessage.Status = '3';
            emailMessage.Client__c = ld.Id;
            emailMessage.Sent_To__c = 'Client';
            emailMessage.fromAddress = 'support@eazeconsulting.com';
            emailMessage.fromName = 'Eaze Support';
            emailMessage.toAddress = ld.Email;
            emailMessage.CcAddress = Label.Funding_Payment_CcAddresses;
            emailMessage.Subject = 'Funding Payment Reminder';
            emailMessage.TextBody = body;
            EmailMessageList.add(emailMessage);

        }
        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
        update leadList;
        insert EmailMessageList;
    }
}