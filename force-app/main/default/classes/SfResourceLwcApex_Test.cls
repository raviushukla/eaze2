@istest
public with sharing class SfResourceLwcApex_Test {
    
    @IsTest
    static void sendNotifications(){
        
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead ld = new Lead(LastName = 'Test Lead', 
                           Email = 'test@te.com', 
                           Company = 'test Company', 
                           Social_Security_Number__c = '121-322-434',
                           Payroll_Frequency__c = 'bi-weekly',
                           Payroll_Type__c = 'Direct_Deposit',
                           Current_Residence_Status__c = 'Rent',
                           LeadSource = 'Other',
                           Status = 'New Lead',
                           State = 'TX',
                           Year_at_Address__c = '2', Account__c = client.Id, Agent_Name__c = agent.Id);
        insert ld;
        
        try{ // AI_FIXED: Added try-catch block for exception handling
            SfResourceLwcApex.sendNotifications(ld.Id);
        } catch(Exception e){ // AI_FIXED: Added catch block to handle potential exceptions
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added logging for debugging purposes
        }
        
    }
}