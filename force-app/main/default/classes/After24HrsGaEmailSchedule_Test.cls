@isTest
public class After24HrsGaEmailSchedule_Test {
	
    static testMethod void sendEmail(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        Contact con = new Contact(LastName = 'Test Contact', Email = 'test@test.com');
        insert con;
        
        acc.Primary_Contact__c = con.Id;
        update acc;
        
        Guaranteed_Approval_Application__c gaObj = new Guaranteed_Approval_Application__c(Account__c = acc.Id);
        insert gaObj;
        
        String jobName = 'Test';
        // AI_FIXED: Removed direct scheduling using System.schedule as it's not reliable for testing and can lead to unpredictable test results.  Instead, we'll simulate the scheduled job execution.
        After24HrsGaEmailSchedule schObj = new After24HrsGaEmailSchedule();
        schObj.recordId = gaObj.Id;
        
        // AI_FIXED: Simulate the scheduled job execution by directly calling the execute method.
        schObj.execute(null); 
    }
}