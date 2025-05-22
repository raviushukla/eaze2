@isTest
public class LeadListForAccountCls_Test {
    testmethod static void runtest(){
        Account ac = new Account(Name='test');
        insert ac;
        Contact con = new Contact( lastName='test', accountid=ac.id, email='test@gmail.com', Agent_Code__c = 'ABCDE123');
        insert con;
        
        Profile p = [SELECT Id FROM Profile WHERE UserType = 'CspLitePortal' Limit 1 ];
        
        User u = new User(
            Alias = 'testu',
            Email = 'test@unitingambition.com',
            EmailEncodingKey = 'UTF-8',
            contactId = con.id,
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            TimeZoneSidKey='America/Los_Angeles', 
            ProfileId = p.Id,
            UserName='test@unitingambition.com'
        );
        
        System.runAs( u ) {
            Lead ld = new Lead();
            ld.LastName = 'test';
            ld.Agent_Code__c = 'ABCDE123';
            ld.Agent_Name__c = con.id;
            ld.Status ='Pre-Approved Pending Income Verification';
            ld.Loan_Amount__c = 10000;
            ld.Social_Security_Number__c = '124566541';
            ld.Date_of_Birth__c = date.today();
            ld.Income_Source_1__c = 'Employed';
            ld.MobilePhone = '45612352';
            insert ld;
            LeadListForAccountCls.getLeadsApex(); 
        }       
        
    }
}