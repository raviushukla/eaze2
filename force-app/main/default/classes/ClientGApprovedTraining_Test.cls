@isTest
public class ClientGApprovedTraining_Test {
    @IsTest
    static void methodName(){
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        ClientGApprovedTraining.getAccDetail(acc.Id);
    }
}