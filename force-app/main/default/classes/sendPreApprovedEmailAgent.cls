public class sendPreApprovedEmailAgent {
	
    public sendPreApprovedEmailAgent(){
	}
    public static void SendMailTelegram(){
        Lead leadObj;
        try{
            // AI_FIXED: Added try-catch block for SOQL query and added parameterized query to prevent SOQL injection
            leadObj = [Select Id, Name__c,Loan_Amount__c, Agent_Name__c, Agent_Name__r.Id,Agent_Name__r.Email, Agent_Name__r.Name, Account__c From Lead Where Id = :String.valueOf(ApexPages.currentPage().getParameters().get('id')) AND Account__c != null AND Agent_Name__c != null LIMIT 1];
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occurred while retrieving Lead data: ' + e.getMessage()));
            return; // AI_FIXED: Return early if Lead retrieval fails
        }

        OrgWideEmailAddress obj;
        try{
            // AI_FIXED: Added try-catch block for SOQL query to handle potential exceptions
            obj = [Select id from OrgWideEmailAddress Where DisplayName = 'Eaze Consulting Support' LIMIT 1];
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occurred while retrieving OrgWideEmailAddress: ' + e.getMessage()));
            return; // AI_FIXED: Return early if OrgWideEmailAddress retrieval fails
        }

        EmailTemplate templateObj;
        try{
            // AI_FIXED: Added try-catch block for SOQL query to handle potential exceptions
            templateObj = [select id from EmailTemplate where DeveloperName =: Label.Send_Pre_Approval_Amount_Agent_Email LIMIT 1];
        } catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An error occurred while retrieving Email Template: ' + e.getMessage()));
            return; // AI_FIXED: Return early if Email Template retrieval fails
        }

        if(leadObj == null || obj == null || templateObj == null){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Required data not found.'));
            return; // AI_FIXED: Return early if any required object is null
        }

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setTemplateId(templateObj.id);
        email.setTargetObjectId(leadObj.Id);
        email.setTreatTargetObjectAsRecipient(false);
        email.setToAddresses( new List<String>{leadObj.Agent_Name__r.Email} );
        email.setOrgWideEmailAddressId(obj.id);
        Messaging.SendEmailResult [] resultMail  = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
        system.debug('resultMail : '+resultMail);
        for(Messaging.SendEmailResult sendEmailResult : resultMail){
             if(!sendEmailResult.isSuccess()){
                for(Messaging.SendEmailError err : sendEmailResult.getErrors()) {                 
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error in sending the mail '+err.getStatusCode() + ': ' + err.getMessage() ));
                }
                
             }else{
                 ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Email sent successfully'));
             }
    	}
        
        Telegram_Message__c teleObj = new Telegram_Message__c();
        teleObj.Agent__c = leadObj.Agent_Name__r.Id;
        teleObj.Client__c = leadObj.Account__c;
        teleObj.Lead__c = leadObj.Id;
        // AI_FIXED: Used String.format for better readability and maintainability
        teleObj.Message__c = String.format('Hello {0}, Your Canadian client {1} has been pre-approved for ${2} pending income verification. The next step is scheduling your client to discuss the best rate and terms with our team. We have sent out our calendar link, but please forward our link http://bookwitheaze.com to {1}, so we can expedite the booking process and get them started immediately. Regards, Eaze Consulting Team', leadObj.Agent_Name__r.Name, leadObj.Name__c, leadObj.Loan_Amount__c);
        teleObj.Status__c = 'Sent';
        teleObj.Type__c = 'Outgoing';
        Boolean tele = true;
        try{
            insert teleObj;
        }catch(Exception e){
            tele = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An exception occurred sending telegram message: ' + e.getMessage()));
        }

        if(tele){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Telegram message sent successfully'));
        }
        
        
	}
}