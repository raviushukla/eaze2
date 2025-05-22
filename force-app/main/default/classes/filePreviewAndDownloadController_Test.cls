@isTest
public class filePreviewAndDownloadController_Test {

    testMethod static void getRelatedFilesByRecordId(){
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
        
        List<ContentVersion> testContentVersions = new List<ContentVersion>();
        for (Integer i = 0; i < 5; i++) {
            ContentVersion cv = new ContentVersion();
            cv.Title = 'Test CV ' + i;
            cv.PathOnClient = 'Test Path ' + i;
            cv.VersionData = Blob.valueOf('Test Content Data ' + i);
            cv.Oasis_Instant_Approval__c = True;
            testContentVersions.add(cv);
        }
        
        insert testContentVersions;
        
        List<ContentVersion> contentVersionList = [SELECT ContentDocumentId FROM ContentVersion WHERE Id IN: testContentVersions];
        
        List<ContentDocumentLink> cdlList = new List<ContentDocumentLink>();
        for(ContentVersion cv : contentVersionList){
            ContentDocumentLink cdl = New ContentDocumentLink();
            cdl.LinkedEntityId = testAccount.Id;
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.ShareType = 'v';
            cdlList.add(cdl);   
        }
        insert cdlList;
		
        Test.startTest();
        filePreviewAndDownloadController.getRelatedFilesByRecordId(testAccount.Id);
        Test.stopTest();
    }
}