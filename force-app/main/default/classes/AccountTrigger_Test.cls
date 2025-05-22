@isTest
public class AccountTrigger_Test {
    public static testMethod void method1(){
		Account accTest = new Account(Name = 'Test Account');
        insert accTest;
    }
}