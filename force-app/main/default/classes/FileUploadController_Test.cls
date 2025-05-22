@isTest
public class FileUploadController_Test {
    @IsTest
    static void testFunc(){
        Account acc = new Account( name = 'Test Client');
        insert acc;
        ApexPages.currentPage().getParameters().put('AccountId',acc.Id);
        Test.startTest();
        FileUploadController obj = new FileUploadController();
        obj.file = Blob.valueOf('Test File');
        obj.fileName = 'Test File';
        obj.upload();
        Test.stopTest();
        
    }
}