public without sharing class SendClientBackendCredentials {
    
    @AuraEnabled
    public static String sendEmail(String clientCode, String emailParam, String phoneNum, String name){
        String result = '';
        String email = '';
        String password = '';
        Boolean agentExist = false;
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:Label.Login_Credentials_Email_Template];
        OrgWideEmailAddress owea = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE DisplayName='Eaze Consulting Support'];
        Task taskObj = new Task();
        try {
            List<Contact> conList = [Select Id, Name, Email, Password__c From Contact Where Email =: emailParam AND Account.Client_Code__c =: clientCode];
            Account acc = new Account();
            if(conList.size() == 0){
                acc = [Select Id, Primary_Contact__r.Email, Primary_Contact__r.Password__c, Primary_Contact__r.Name from Account Where Client_Code__c =: clientCode];
                email = acc.Primary_Contact__r.Email;
                password = acc.Primary_Contact__r.Password__c;
            }else{
                agentExist = true;
                email = conList[0].Email;
                password = conList[0].Password__c;
            }
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = new String[] { emailParam };
            if(agentExist){
                message.setTargetObjectId(conList[0].Id);
                message.setTreatTargetObjectAsRecipient(true);
            }else{
                message.setTargetObjectId(acc.Primary_Contact__c);
                message.setTreatTargetObjectAsRecipient(false);
            }
            message.setTemplateId(et.Id);
            message.setOrgWideEmailAddressId(owea.Id);
            emailList.add(message); 
            if(!agentExist){
                Messaging.SingleEmailMessage primaryConEmail = new Messaging.SingleEmailMessage();
                primaryConEmail.setTargetObjectId(acc.Primary_Contact__c);
                primaryConEmail.setTreatTargetObjectAsRecipient(true);
                primaryConEmail.setOrgWideEmailAddressId(owea.Id);
                primaryConEmail.setSubject('EAZE Funding Analytics back office login');
                primaryConEmail.htmlbody = '<p>Hello '+acc.Primary_Contact__r.Name+',</p>'+
                                            +'<p>Your Eaze Analytics Backend Portal Credentials are accessed by below person if not please contact our support:</p>'+
                                            +'<p>Name : '+name+'</p>'+
                                            +'<p>Phone Number : '+phoneNum+'</p>'+
                                            +'<p>Email : '+emailParam+'</p>'+
                                            +'<p>And here’s a short <a href="https://www.loom.com/share/4302a1e8367144febea20c450b25f9fa?sid=39568934-592e-45ad-9f03-512b455fcb1d" target="_blank">video walkthrough</a> of how it all works! </p>'+
                                            +'<p>Regards</p>'+
                                            +'<p>Eaze Consulting</p>';
                emailList.add(primaryConEmail);                 
                
                taskObj = new Task(IsVisibleInSelfService = True, Status = 'Completed', Subject = 'Eaze Analytics Credentails Shared with '+name+' '+phoneNum+' '+emailParam, WhoId = acc.Primary_Contact__c);
            }

            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailList);
            if (results[0].success) {
                insert taskObj;
                System.debug('The email was sent successfully.');
                result = 'The email was sent successfully.';
            } else {
                System.debug('The email failed to send: '
                    + results[0].errors[0].message);
                    result = results[0].errors[0].message;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return result;
    }
}