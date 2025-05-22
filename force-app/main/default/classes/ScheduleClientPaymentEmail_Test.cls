@isTest
public class ScheduleClientPaymentEmail_Test {
	
    static testMethod void sendEmail(){
        
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Date dt = system.Today().addMonths(-1);
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          GA_Lead__c = True,
                          Closed_Date__c = dt);
        insert l;
        
        String CRON_EXP = '0 6 * * * ?';
        
        Test.startTest();
        String jobId = System.schedule('Send Message', CRON_EXP, new ScheduleClientPaymentEmail());
        Test.stopTest();
    }
}