/*
    Umesh Rana 8 Jan 2024
    The apex class is called from a LWC "SendToBelEAZEChatBtn", which is further called from a VF Page SendToBelEAZEChatVF.
    Link Button is created on Lead object.
    -- Creating a telegram message to send to Eaze team.
*/
public with sharing class SendToBelEAZEChatBtnApex {

    @AuraEnabled
    public static String createTelegramMsgRecord(String recordId) {
        System.debug('recordId '+recordId);
        String returnmsg = '';
        try {
            List<Lead> leadRecords = [SELECT Id, Name,Account__c,Account__r.Name,MobilePhone,Agent_Name__r.Name,Agent_Name__c,Account__r.SF_Max_Loan_Amount__c, 
                               Account__r.SFC_Password__c,Account__r.SFC_Username__c,Account__r.Company_APR__c,Loan_Amount__c
                               FROM Lead WHERE Id = :recordId LIMIT 1];
            
           if(!leadRecords.isEmpty()){ 
            
            List<Telegram_Group__c> telegramgrp   = [select id from Telegram_Group__c where name=: Label.SendToBelEAZEChatLabel];
              
            String msgBody  = MsgConstruct(leadRecords[0]);
            Telegram_Message__c msg = new Telegram_Message__c();
            msg.Lead__c = leadRecords[0].Id;
            msg.Message__c = msgBody;
            msg.Telegram_Group__c = telegramgrp.size()>0 ? telegramgrp[0].Id : null;
            msg.Status__c = 'Sent';
            msg.Type__c = 'Outgoing';     
            insert msg;
            system.debug('msg.Id'+msg.Id);   
            returnmsg = 'Success';   
            }
           return returnmsg;
        } catch (Exception e) {
            throw new AuraHandledException('Error creating  record: ' + e.getMessage());
        }
    }
    
    public static String MsgConstruct(Lead ld){
        String msgBody;              
        msgBody =         'Name: '+ld.Name +'\n';
        msgBody +=        'Mobile: '+ld.MobilePhone +'\n';
        msgBody +=       'Account: '+ (ld.Account__c !=null ? ld.Account__r.Name : '') +'\n';
        msgBody +=       'Agent Name: '+(ld.Agent_Name__c !=null ? String.valueof(ld.Agent_Name__r.Name) : '')  +'\n';
        msgBody +=       'Loan Amount: '+ld.Loan_Amount__c +'\n';    
        msgBody +=       'SF Max Loan Amount: '+ (ld.Account__c !=null && ld.Account__r.SF_Max_Loan_Amount__c !=null ? String.valueof(ld.Account__r.SF_Max_Loan_Amount__c) : '') +'\n';    
        msgBody +=       'Company APR: '+ (ld.Account__c !=null  && ld.Account__r.Company_APR__c !=null  ? String.valueof(ld.Account__r.Company_APR__c) : '') +'\n';    
        msgBody +=       'SFC Username: '+ (ld.Account__c !=null && ld.Account__r.SFC_Username__c !=null ? ld.Account__r.SFC_Username__c : '') +'\n';    
        msgBody +=       'SFC Password: '+ (ld.Account__c !=null && ld.Account__r.SFC_Password__c !=null ? ld.Account__r.SFC_Password__c : '') +'\n';    

        
        return msgBody;
    }
}