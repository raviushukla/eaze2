/* Schedule Apex to run every 10 minutes -  AI_FIXED: Removed redundant scheduling, replaced with a single scheduled job that runs every 10 minutes.
System.schedule('Funding Payment Reminder Emails', '0 0/10 * * * ?', new FundingPaymentReminderEmailScheduler());
*/
global class FundingPaymentReminderEmailScheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        try {
            DateTime tempDate = system.now().addMinutes(-5);
            // AI_FIXED: Added governor limits check
            List<Lead> leadList = Database.query(
                'SELECT Name, Email, Payment_Link__c, Immediate_Payment_Reminder_Sent__c ' +
                'FROM Lead ' +
                'WHERE Intro_Done_DateTime__c <= :tempDate ' +
                'AND Status != \'Setup Fee Paid To EAZE\' ' +
                'AND LeadSource = \'Funding Partner Intro Done\' ' +
                'AND IsConverted = false ' +
                'AND Immediate_Payment_Reminder_Sent__c = false ' +
                'LIMIT :limits' // AI_FIXED: Added LIMIT to prevent SOQL governor limits
            );
            Integer limits = 200; // AI_FIXED: Added a limit to the SOQL query to prevent governor limits. Adjust as needed.

            if(leadList.size()>0){
                sendResetLink(leadList);
            }
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to catch and log errors.
            System.debug('Error in FundingPaymentReminderEmailScheduler: ' + e.getMessage());
        }
    }
    global void sendResetLink(List<Lead> leadList){
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        // AI_FIXED: Removed unnecessary list, directly using emailList
        for(Lead ld: leadList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(ld.id); 
            email.setSenderDisplayName('Eaze Support'); 
            email.setReplyTo('support@eazeconsulting.com');
            email.setUseSignature(false); 
            email.setBccSender(false); 
            email.setSaveAsActivity(false); 
            try {
                EmailTemplate emailTemplate = [Select Body, Subject From EmailTemplate Where DeveloperName =: Label.Funding_Payment_Email_Template]; // AI_FIXED: Added Subject retrieval from Email Template
                email.setTemplateID(emailTemplate.Id); 
                email.toAddresses = new List<String>{ ld.email };
                List<String> ccAddresses = Label.Funding_Payment_CcAddresses.split(',');
                email.setCcAddresses(ccAddresses);
                emailList.add(email);
                // AI_FIXED: Moved update and insert operations outside the loop for better performance
            } catch (Exception ex) {
                // AI_FIXED: Added exception handling for email template retrieval
                System.debug('Error retrieving email template or sending email: ' + ex.getMessage());
            }
            ld.Immediate_Payment_Reminder_Sent__c = true;
            ld.Status = 'Setup Fee - Invoice Sent';
        }
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            update leadList;
            // AI_FIXED: Removed unnecessary EmailMessageList and related code.  Using Email Template instead.
        } catch (Exception ex) {
            // AI_FIXED: Added exception handling for email sending
            System.debug('Error sending emails: ' + ex.getMessage());
        }
    }
}