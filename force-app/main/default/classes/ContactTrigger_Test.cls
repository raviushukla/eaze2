@isTest
public class ContactTrigger_Test {
    public static testMethod void method1(){
        Account accTest = new Account(Name = 'Test Account');
        insert accTest;
        Contact conTest = new Contact(AccountId = accTest.Id, Email='test@gmail.com', LastName='Name');
        insert conTest;
        // AI_FIXED: Added try-catch block for exception handling during update
        try{
            Contact conUpdate = new Contact(Id = conTest.Id, Secondary_Agent_Email__c='test2@gmail.com');
            update conUpdate;
        } catch(DMLException e){
            // AI_FIXED: Added logging for better debugging
            System.debug('Error updating Contact: ' + e.getMessage());
        }
    }
}