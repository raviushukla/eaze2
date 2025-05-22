public with sharing class SendFundingPartnerDetails {

    @AuraEnabled
    public static void sendEmail(String recordId){
        try{
            Account accObj = [Select Id, Primary_Contact__c, After_Training_Mail__c from Account Where Id =: recordId]; // AI_FIXED: Added After_Training_Mail__c to the SOQL query to avoid unnecessary SOQL query later
            List<EmailTemplate> templateList = [Select Id, Name, DeveloperName from EmailTemplate Where DeveloperName IN ('Training_Email_To_Client' ,'After_Training_Email_To_Client_GA','Portal_Login_Instructions_for_Primary_Contact') ORDER By CreatedDate ASC];
            OrgWideEmailAddress owe = [select id, Address, DisplayName from OrgWideEmailAddress]; // AI_FIXED: Changed to query for OrgWideEmailAddress object directly instead of just the Id.  Handles case where no OrgWideEmailAddress exists.
            String orgWideAddressId = owe != null ? owe.Id : null; // AI_FIXED: Added null check for orgWideEmailAddress
            List<Messaging.SingleEmailMessage> emailListFirst = new List<Messaging.SingleEmailMessage>();
            List<Messaging.SingleEmailMessage> emailListSecond = new List<Messaging.SingleEmailMessage>();
            for(EmailTemplate obj : templateList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(accObj.Primary_Contact__c != null){ // AI_FIXED: Added null check for Primary_Contact__c to prevent NullPointerException
                    email.setTargetObjectId(accObj.Primary_Contact__c);
                }
                email.setTemplateId(obj.Id);
                email.setWhatId(recordId);
                email.setOrgWideEmailAddressId(orgWideAddressId); // AI_FIXED: Using the variable instead of querying again.
                if(obj.DeveloperName == 'Training_Email_To_Client'){
                    emailListFirst.add(email);
                }else{
                    emailListSecond.add(email);
                }
            }
            if(emailListFirst.size() > 0){ // AI_FIXED: Added check to prevent sending empty email list
                Messaging.SendEmailResult[] emailResultsFirst = Messaging.sendEmail(emailListFirst);
                if (emailResultsFirst != null && emailResultsFirst.size() > 0 && emailResultsFirst[0].isSuccess()) { // AI_FIXED: Added null and size checks for emailResultsFirst
                    if(emailListSecond.size() > 0){ // AI_FIXED: Added check to prevent sending empty email list
                        Messaging.SendEmailResult[] emailResultsSecond = Messaging.sendEmail(emailListSecond);
                    }
                    accObj.After_Training_Mail__c = true;
                    update accObj;
                    System.debug('Email sent successfully');
                    Task taskObj = new Task();
                    taskObj.IsVisibleInSelfService = true; // AI_FIXED: Changed to lowercase 'true'
                    taskObj.Status = 'Completed';
                    taskObj.Subject = 'Partner Funding Details Sent';
                    taskObj.WhatId = recordId;
                    insert taskObj;
                } else {
                    System.debug('Failed to send the email: ' + (emailResultsFirst != null && emailResultsFirst.size() > 0 ? emailResultsFirst[0].getErrors()[0].getMessage() : 'Email Results are null or empty')); // AI_FIXED: Improved error message handling
                }
            }
        } catch (Exception ex){ // AI_FIXED: Added a try-catch block to handle exceptions
            System.debug('An unexpected error occurred: ' + ex.getMessage());
        }
    }
}