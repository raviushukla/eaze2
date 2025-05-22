@isTest
public class ClientLogo_Test {
	static testMethod void testAttachments()
    {
    	Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
 		Account acc = [Select Client_code__c From Account Where Id=: client.Id];
        Attachment attach=new Attachment();   	
    	attach.Name='clientlogo';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=client.id;
        insert attach;
        
        ApexPages.currentPage().getParameters().put('cl',acc.Client_code__c);
        ClientLogo c = new ClientLogo();
    }
}