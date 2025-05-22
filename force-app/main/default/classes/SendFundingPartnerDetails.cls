public with sharing class SendFundingPartnerDetails {

    @AuraEnabled
    public static void sendEmail(String recordId){
        Account accObj = [Select Id, Primary_Contact__c from Account Where Id =: recordId];
        List<EmailTemplate> templateList = [Select Id, Name, DeveloperName from EmailTemplate Where DeveloperName IN ('Training_Email_To_Client' ,'After_Training_Email_To_Client_GA','Portal_Login_Instructions_for_Primary_Contact') ORDER By CreatedDate ASC];
        String orgWideAddressId = [select id, Address, DisplayName from OrgWideEmailAddress].Id;
        List<Messaging.SingleEmailMessage> emailListFirst = new List<Messaging.SingleEmailMessage>();
        List<Messaging.SingleEmailMessage> emailListSecond = new List<Messaging.SingleEmailMessage>();
        for(EmailTemplate obj : templateList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTargetObjectId(accObj.Primary_Contact__c);
            email.setTemplateId(obj.Id);
            email.setWhatId(recordId);
            email.setOrgWideEmailAddressId(orgWideAddressId);
            if(obj.DeveloperName == 'Training_Email_To_Client'){
            	emailListFirst.add(email);
            }else{
                emailListSecond.add(email);
            }
        }
        Messaging.SendEmailResult[] emailResultsFirst = Messaging.sendEmail(emailListFirst);
        if (emailResultsFirst[0].isSuccess()) {
            Messaging.SendEmailResult[] emailResultsSecond = Messaging.sendEmail(emailListSecond);
            accObj.After_Training_Mail__c = true;
            update accObj;
            System.debug('Email sent successfully');
            Task taskObj = new Task();
            taskObj.IsVisibleInSelfService = True;
            taskObj.Status = 'Completed';
            taskObj.Subject = 'Partner Funding Details Sent';
            taskObj.WhatId = recordId;
            insert taskObj;
        } else {
            System.debug('Failed to send the email: ' + emailResultsFirst[0].getErrors()[0].getMessage());
        }

    }
}