@isTest
public class GA_ApplicationController_Test {
	
    testMethod static void testFun(){
        Guaranteed_Approval_Application__c obj = new Guaranteed_Approval_Application__c();
        insert obj;
        Test.StartTest(); 
        PageReference pageRef = Page.GA_DataConfirmation;
        pageRef.getParameters().put('id', obj.Id);
        Test.setCurrentPage(pageRef);
        GA_ApplicationController gaObj = new GA_ApplicationController();
 		Test.StopTest();
    }
}