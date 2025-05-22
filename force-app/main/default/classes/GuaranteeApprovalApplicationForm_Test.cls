@isTest
public class GuaranteeApprovalApplicationForm_Test {
	
    testMethod static void setAccount(){
		
		Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111',MobilePhone='789 789-7896');
        insert agent;

		client.Primary_Contact__c = agent.Id;
		update client;
		
		system.assertEquals(String.valueOf(client.Id), GuaranteeApprovalApplicationForm.findAccount('Test@test.com','987987','Test','','','','',''));      
        system.assertNotEquals(String.valueOf(client.Id), GuaranteeApprovalApplicationForm.findAccount('Test@test.c','654987','Test Test','','','','',''));    
    }
    
    @isTest
    static void testUploadFiles() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test CV ' + i;
            cv.PathOnClient = 'Test Path ' + i;
            cv.VersionData = Blob.valueOf('Test Content Data ' + i);
            insert cv;
            testContentVersions.add(cv);
        }

        List<String> cvIdsList = new List<String>();
        for (ContentVersion cv : testContentVersions) {
            cvIdsList.add(cv.Id);
        }

        // Call the method to be tested
        Test.startTest();
        GuaranteeApprovalApplicationForm.uploadFiles(testAccount.Id, cvIdsList);
        Test.stopTest();
	}
}