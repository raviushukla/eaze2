@istest
public class AutoSendAgreement_AdobeSignSchedulerTest {
    
    static testmethod void test() {
   		Test.startTest();
        String jobId = System.schedule('testBasicScheduledApex',
      		'0 0 0 3 9 ? 2022', 
         	new AutoSendAgreement_AdobeSignScheduler() );
		Test.stopTest();
    }
}