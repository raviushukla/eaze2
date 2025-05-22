@isTest
public class InstantApprovalDocumentUpload_Test {

    testMethod static void uploadFiles(){
        
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test CV ' + i;
            cv.PathOnClient = 'Test Path ' + i;
            cv.VersionData = Blob.valueOf('Test Content Data ' + i);
            testContentVersions.add(cv);
        }
		
        insert testContentVersions;
        
        List<String> cvIdsList = new List<String>();
        for (ContentVersion cv : testContentVersions) {
            cvIdsList.add(cv.Id);
        }
		
        String clientCode = [Select Id, Client_Code__c From Account Where Id =:testAccount.Id].Client_Code__c;
        // Call the method to be tested
        Test.startTest();
        InstantApprovalDocumentUpload.uploadFiles(testAccount.Id, cvIdsList, '1');
        InstantApprovalDocumentUpload.getAcc(clientCode);
        Test.stopTest();
    }
}