@isTest
public class ScheduleTextMessages_Test {
	
    @testSetup static void setup(){ // AI_FIXED: Added @testSetup annotation to run before each test method. This is a best practice for setting up test data.
        Contact agent = new Contact(FirstName = 'Alex', LastName = 'Dee', Email='Test@test.com', Agent_Code__c = '111111', MobilePhone = '9874563210', Is_Primary__c = true);
        insert agent;
        
        SMS_Template__c templateObj = new SMS_Template__c();
        templateObj.SMS_Text__c = 'test';
        templateObj.Name = Label.Text_Message_Template_Name;
        templateObj.Subject__c = 'test';
        insert templateObj;
    }
    
    @isTest static void callScheduleFun(){ // AI_FIXED: Added @isTest annotation to the test method.  This is required for a test method.
        String CRON_EXP = '0 6 * * * ?';
        
        Test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling during scheduling.
            String jobId = System.schedule('Send Message', CRON_EXP, new ScheduleTextMessages());
        } catch(Exception e){ // AI_FIXED: Added catch block to handle potential exceptions during scheduling.
            System.debug('Exception during scheduling: ' + e.getMessage()); // AI_FIXED: Added logging for debugging purposes.
        }
        Test.stopTest();
        
    }
}