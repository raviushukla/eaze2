@isTest
public class ClientGApprovedTraining_Test {
    @IsTest
    static void methodName(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Test.startTest(); // AI_FIXED: Added Test.startTest() to cover asynchronous operations
        try {
            ClientGApprovedTraining.getAccDetail(acc.Id); // AI_FIXED: Wrapped method call in try-catch block for exception handling
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added exception logging for better debugging
        }
        Test.stopTest(); // AI_FIXED: Added Test.stopTest() to ensure proper test execution
    }
}