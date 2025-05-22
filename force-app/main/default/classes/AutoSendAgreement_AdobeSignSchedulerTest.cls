@istest
public class AutoSendAgreement_AdobeSignSchedulerTest {
    
    static testmethod void test() {
   		Test.startTest();
        // AI_FIXED: Removed hardcoded date and used a cron expression that will run the job immediately.  This prevents the test from failing if the year 2022 is passed.
        String jobId = System.schedule('testBasicScheduledApex', '0 0 * * * ?', new AutoSendAgreement_AdobeSignScheduler() ); // AI_FIXED: Changed cron expression to run immediately.
		Test.stopTest();
    }
}