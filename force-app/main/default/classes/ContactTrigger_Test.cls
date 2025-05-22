@isTest
public class ContactTrigger_Test {
    public static testMethod void method1(){
        Account accTest = new Account(Name = 'Test Account');
        insert accTest;
        Contact conTest = new Contact(AccountId = accTest.Id, Email='test@gmail.com', LastName='Name');
        insert conTest;
        Contact conUpdate = new Contact(Id = conTest.Id, Secondary_Agent_Email__c='test2@gmail.com');
        update conUpdate;
    }
}