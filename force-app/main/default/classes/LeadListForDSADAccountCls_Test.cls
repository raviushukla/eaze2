@isTest
public class LeadListForDSADAccountCls_Test {
    testmethod static void runtest(){
        Account ac = new Account(Name='test');
        insert ac;
        Contact con = new Contact( lastName='test', accountid=ac.id, email='test@gmail.com', Agent_Code__c = 'ABCDE123');
        insert con;
        
       
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Agent_Code__c = 'ABCDE123';
        ld.Agent_Name__c = con.id;
        ld.Share_With_DSAD__c = true;
        ld.Status ='Pre-Approved Pending Income Verification';
        ld.Loan_Amount__c = 10000;
        ld.Social_Security_Number__c = '124566541';
        ld.Date_of_Birth__c = date.today();
        ld.Income_Source_1__c = 'Employed';
        ld.MobilePhone = '45612352';
        insert ld;
        LeadListForDSADAccountCls.getLeadsApex(); 
            
        
    }

}