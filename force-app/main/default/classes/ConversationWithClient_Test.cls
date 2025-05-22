@isTest
public class ConversationWithClient_Test {
    static testMethod void fetchClients(){
        
        Lead LD = new Lead( 
            LastName = 'Testing', 
            Date_of_Birth__c = system.today(),
            Status = 'Qualified',
            Loan_Amount__c = 20, 
            Social_Security_Number__c = '30', 
            Income_Source_1__c = 'Employed',
            Email = 'test@wakencode.com', 
            Phone = '123456789',
            LeadSource = 'OEA Application',
            Current_Residence_Status__c = 'Rent',
            Payroll_Type__c = 'Direct_Deposit',
            Payroll_Frequency__c = 'bi-weekly',
            MobilePhone = '987654321');
        insert LD;
        
        Lead LD2 = new Lead( 
            LastName = 'Testing', 
            Date_of_Birth__c = system.today(),
            Status = 'Qualified',
            Loan_Amount__c = 20, 
            Social_Security_Number__c = '30', 
            Income_Source_1__c = 'Employed',
            Email = 'test2@wakencode.com', 
            Phone = '123456789',
            LeadSource = 'OEA Application',
            Current_Residence_Status__c = 'Rent',
            Payroll_Type__c = 'Direct_Deposit',
            Payroll_Frequency__c = 'bi-weekly',
            MobilePhone = '987654321');
        insert LD2;
        
        Twilio_SMS__c twilio = new  Twilio_SMS__c (
            SMS_Body__c='Testing', 
            Type__c='Outgoing', 
            SMS_Recipient__c='345', 
            SMS_Status__c='Sent', 
            Leads__c =LD.Id );
        insert twilio;
        
        Twilio_SMS__c twilio2 = new  Twilio_SMS__c (
            SMS_Body__c='Testing', 
            Type__c='Incoming', 
            SMS_Recipient__c='345', 
            Unseen__c=true, 
            Leads__c =LD.Id );
        insert twilio2;
        
        test.startTest();
        ConversationWithClient.fetchClients();
        ConversationWithClient.fetchConversation(LD.Id);
        ConversationWithClient.sendMessage(LD.Id, 'smsBody', '987654321');
        ConversationWithClient.fetchNotification();
        ConversationWithClient.markSMSasRead(new List<String>{twilio2.Id});
        test.stopTest();
        
    }
    
}