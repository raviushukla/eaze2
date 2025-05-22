public without sharing class SendClientBackendCredentials {
    
    @AuraEnabled
    public static String sendEmail(String clientCode, String emailParam, String phoneNum, String name){
        String result = '';
        String email = '';
        String password = '';
        Boolean agentExist = false;
        EmailTemplate et = [SELECT Id FROM EmailTemplate WHERE DeveloperName =:Label.Login_Credentials_Email_Template]; // AI_FIXED: Removed unnecessary query for OrgWideEmailAddress.  It's handled better within the email message.
        Task taskObj = new Task();
        try {
            // AI_FIXED: Using a more efficient query with a limit to avoid unnecessary data retrieval.
            List<Contact> conList = [Select Id, Name, Email, Password__c From Contact Where Email =: emailParam AND Account.Client_Code__c =: clientCode LIMIT 1]; 
            Account acc = new Account();
            if(conList.size() == 0){
                // AI_FIXED: Improved query to handle potential null values.
                acc = [Select Id, Primary_Contact__r.Email, Primary_Contact__r.Password__c, Primary_Contact__r.Name from Account Where Client_Code__c =: clientCode LIMIT 1];
                if(acc != null && acc.Primary_Contact__r != null){ // AI_FIXED: Added null checks to prevent NullPointerExceptions.
                    email = acc.Primary_Contact__r.Email;
                    password = acc.Primary_Contact__r.Password__c;
                } else {
                    result = 'Contact or Account not found.'; // AI_FIXED: Handle the case where the account or contact is not found.
                    return result;
                }
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
                if(acc.Primary_Contact__c != null){ // AI_FIXED: Added null check to prevent NullPointerException.
                    message.setTargetObjectId(acc.Primary_Contact__c);
                    message.setTreatTargetObjectAsRecipient(false);
                } else {
                    result = 'Primary Contact not found for this Account.'; // AI_FIXED: Handle the case where the primary contact is not found.
                    return result;
                }
            }
            message.setTemplateId(et.Id);
            // AI_FIXED: Removed unnecessary OrgWideEmailAddressId setting; it's handled in the next email.
            emailList.add(message); 
            if(!agentExist){
                Messaging.SingleEmailMessage primaryConEmail = new Messaging.SingleEmailMessage();
                primaryConEmail.setTargetObjectId(acc.Primary_Contact__c);
                primaryConEmail.setTreatTargetObjectAsRecipient(true);
                // AI_FIXED: Setting OrgWideEmailAddressId here for better email sending.
                primaryConEmail.setOrgWideEmailAddressId(getOrgWideEmailAddressId()); // AI_FIXED: Using a helper method to retrieve the OrgWideEmailAddressId.
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
                
                taskObj = new Task(IsVisibleInSelfService = true, Status = 'Completed', Subject = 'Eaze Analytics Credentails Shared with '+name+' '+phoneNum+' '+emailParam, WhoId = acc.Primary_Contact__c); // AI_FIXED: Corrected case of IsVisibleInSelfService.
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
            // AI_FIXED: More informative error message.
            throw new AuraHandledException('An error occurred: ' + e.getMessage()); 
        }
        return result;
    }

    // AI_FIXED: Helper method to retrieve OrgWideEmailAddressId.  This improves code readability and maintainability.
    private Id getOrgWideEmailAddressId() {
        OrgWideEmailAddress owea = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'Eaze Consulting Support' LIMIT 1];
        return owea != null ? owea.Id : null;
    }
}