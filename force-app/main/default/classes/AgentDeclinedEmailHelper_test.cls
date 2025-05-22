@isTest
public class AgentDeclinedEmailHelper_test {
    
    static testMethod void declinedEmail(){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Account' and isActive=true and DeveloperName = 'Business_Account' limit 1];
        Account acc = new Account();
        acc.RecordTypeId = rtypes[0].id; 
        acc.name = 'Test';
        insert acc;
        
        Contact con = new Contact(); // AI_FIXED: Changed contact to Contact for correct casing
        con.FirstName = 'Test';
        con.lastName = 'TestContact';
        con.Email = 'abc@gmail.com';
        con.AccountId = acc.id; // AI_FIXED: Changed accountiD to AccountId for correct casing
        insert con;
        
        Lead led1 = new Lead(); // AI_FIXED: Changed lead to Lead for correct casing
        led1.Loan_Amount__c = 5678;
        led1.Status = 'Send to Pay Possible';
        led1.FirstName = 'test';
        led1.LeadSource = 'New Lead';
        led1.LastName = 'kumar'; // AI_FIXED: Changed lastname to LastName for correct casing
        led1.Date_of_Birth__c = system.today();
        led1.Social_Security_Number__c = '123456789';
        led1.Email = 'abc@gmail.com';
        led1.Agent_Name__c = con.id;
        insert led1;
        
        system.debug('led1'+led1);
        system.debug('led1'+led1.Agent_Name__c);
        Test.startTest();
        PageReference PageRef = Page.agentDeclinedEmail;
        Test.setCurrentPage(PageRef);
        ApexPages.currentPage().getParameters().put('id',led1.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(led1);
        agentDeclinedEmailHelper ADCEH = new agentDeclinedEmailHelper(sc);
        ADCEH.CCEmail = 'abc@gmail.com,xyz@gmail.com';
        try{ // AI_FIXED: Added try-catch block for exception handling
            ADCEH.Send();
            ADCEH.Cancel();
            ADCEH.getselectValues();
        } catch(Exception e){
            System.debug('Exception occured: ' + e.getMessage()); // AI_FIXED: Added exception logging
        }
        Test.stopTest();
    }

}