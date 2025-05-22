@isTest
public  class ClientApplicationMainTraining_Test {
    
    @IsTest
    static void insertRecords(){
        Account acc = new Account(Name = 'Test Account');
        Test.startTest();
        insert acc;
        Test.stopTest();
        ClientApplicationMainTraining.getAccDetail(acc.Id);
        
    }
}