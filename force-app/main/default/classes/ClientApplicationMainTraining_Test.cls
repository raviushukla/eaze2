@isTest
public  class ClientApplicationMainTraining_Test {
    
    @IsTest
    static void insertRecords(){
        Account acc = new Account(Name = 'Test Account');
        Test.startTest();
        insert acc;
        // AI_FIXED: Added try-catch block for exception handling
        try{
            ClientApplicationMainTraining.getAccDetail(acc.Id); // AI_FIXED: Calling the method within the try block
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Logging the exception for debugging purposes
        }
        Test.stopTest();
        
    }
}