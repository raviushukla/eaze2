@isTest
public class EazeEliteProgramFormTest {
    
    @testSetup
    static void setupTestData() {
        // Create test Account
        Account testAccount = new Account(Name = 'Test Business');
        insert testAccount;
        
        // Create test ContentVersion
        ContentVersion cv = new ContentVersion(
            Title = 'Test File',
            PathOnClient = 'TestFile.pdf',
            VersionData = Blob.valueOf('Test Data'),
            IsMajorVersion = true
        );
        insert cv;
    }
    
    @isTest
    static void testFindAccount() {
        Test.startTest();
        
        // Test finding an existing account
        String accId = EazeEliteProgramForm.findAccount('test@email.com', 'Test Business', null, null, null);
        System.assertNotEquals(null, accId, 'Account ID should not be null');
        
        // Test when account does not exist
        String noAccId = EazeEliteProgramForm.findAccount('test@email.com', 'Non-Existent Business', null, null, null);
        System.assertEquals('', noAccId, 'Account ID should be empty string when no match');
        
        Test.stopTest();
    }
    
    @isTest
    static void testUploadFiles() {
        // Get test ContentVersion
        ContentVersion cv = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        // Create a test record (Account used for demonstration)
        Account testAccount = new Account(Name = 'Upload Test Account');
        insert testAccount;
        
        Test.startTest();
        
        // Call uploadFiles method
        EazeEliteProgramForm.uploadFiles(testAccount.Id, new List<String>{cv.Id});
        
        // Verify ContentDocumentLink was created
        List<ContentDocumentLink> cdlList = [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :testAccount.Id];
        System.assertEquals(1, cdlList.size(), 'One ContentDocumentLink should have been created');
        
        Test.stopTest();
    }
}