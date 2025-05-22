@isTest
public class ApexCommonHelper_Test {
    public static testMethod void getAllField(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        ApexCommonHelper.getAllField('Account');
        ApexCommonHelper.generateCode(10);
        ApexCommonHelper.validateNewAgentCode('AAAAAAAAAA');
        ApexCommonHelper.validateNewClientCode('AAAAA');
        ApexCommonHelper.formatPhoneNum('+11111111111');
        DateTime dt  = Datetime.newInstance(2020, 2, 1, 00, 00, 00);
        ApexCommonHelper.dateTimeToUserTimeZone(dt, agent.Id);
    }
}