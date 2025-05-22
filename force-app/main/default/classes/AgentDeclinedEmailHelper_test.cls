@isTest
public class AgentDeclinedEmailHelper_test {
    
    static testMethod void declinedEmail(){
        List<RecordType> rtypes = [Select Name, Id From RecordType where sObjectType='Account' and isActive=true and DeveloperName = 'Business_Account' limit 1];
        Account acc = new Account();
        acc.RecordTypeId = rtypes[0].id; 
        acc.name = 'Test';
        Insert acc;
        
        contact con = new contact();
        con.FirstName = 'Test';
        con.lastName = 'TestContact';
        con.Email = 'abc@gmail.com';
        con.accountiD = acc.id;
        insert con;
        
        lead led1 = new lead();
        led1.Loan_Amount__c = 5678;
        led1.Status = 'Send to Pay Possible';
        led1.FirstName = 'test';
        led1.LeadSource = 'New Lead';
        led1.lastname = 'kumar';
        led1.Date_of_Birth__c = system.today();
        led1.Social_Security_Number__c = '123456789';
        led1.Email = 'abc@gmail.com';
        led1.Agent_Name__c = con.id;
        insert led1;
        
        system.debug('led1'+led1);
        system.debug('led1'+led1.Agent_Name__c);
        test.startTest();
        PageReference PageRef = Page.agentDeclinedEmail;
            Test.setCurrentPage(PageRef);
            ApexPages.currentPage().getParameters().put('id',led1.id);
        	Apexpages.StandardController sc = new Apexpages.StandardController(led1);
            agentDeclinedEmailHelper ADCEH = new agentDeclinedEmailHelper(sc);
        	ADCEH.CCEmail = 'abc@gmail.com,xyz@gmail.com';
            ADCEH.Send();
            ADCEH.Cancel();
            ADCEH.getselectValues();
        test.stopTest();
    }

}