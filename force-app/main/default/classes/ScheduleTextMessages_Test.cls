@isTest
public class ScheduleTextMessages_Test {
	
    testMethod static void callScheduleFun(){
        Contact agent = new Contact(FirstName = 'Alex', LastName = 'Dee', Email='Test@test.com', Agent_Code__c = '111111', MobilePhone = '9874563210', Is_Primary__c = true);
        insert agent;
        
        SMS_Template__c templateObj = new SMS_Template__c();
        templateObj.SMS_Text__c = 'test';
        templateObj.Name = Label.Text_Message_Template_Name;
        templateObj.Subject__c = 'test';
        insert templateObj;
        
        String CRON_EXP = '0 6 * * * ?';
        
        Test.startTest();
        String jobId = System.schedule('Send Message', CRON_EXP, new ScheduleTextMessages());
        Test.stopTest();
        
    }
}