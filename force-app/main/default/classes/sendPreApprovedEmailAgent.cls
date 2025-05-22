public class sendPreApprovedEmailAgent {
	
    public sendPreApprovedEmailAgent(){
	}
    public static void SendMailTelegram(){
        Lead leadObj = [Select Id, Name__c,Loan_Amount__c, Agent_Name__c, Agent_Name__r.Id,Agent_Name__r.Email, Agent_Name__r.Name, Account__c From Lead Where Id =: ApexPages.currentPage().getParameters().get('id') AND Account__c != null AND Agent_Name__c != null ];
        OrgWideEmailAddress obj = [Select id from OrgWideEmailAddress Where DisplayName = 'Eaze Consulting Support'];
        Emailtemplate templateObj = [select id from Emailtemplate where DeveloperName =: Label.Send_Pre_Approval_Amount_Agent_Email];
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
        teleObj.Message__c = 
        
        'Hello '+leadObj.Agent_Name__r.Name+','+

        ' Canadian Applicant'+
        
        ' Your Canadian client '+ leadObj.Name__c +' has been pre-approved for $'+ Integer.valueOf(leadObj.Loan_Amount__c) +' pending income verification.' +
        
        ' The next step is scheduling your client to discuss the best rate and terms with our team.'+
        
        ' We have sent out our calendar link, but please forward our link http://bookwitheaze.com to '+ leadObj.Name__c +', so we can expedite the booking process and get them started immediately.'+
        
        ' Regards,'+
        
        ' Eaze Consulting Team';
        
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