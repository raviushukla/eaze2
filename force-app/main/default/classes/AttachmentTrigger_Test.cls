@isTest
public class AttachmentTrigger_Test {
    @isTest static void AttachmentMethod(){
        Account acc = new Account(Name = 'acctest');
        Insert acc;
        Account acc1 = new Account(Name = 'acctest1');
        Insert acc1;
        
        Contact con =new Contact(LastName = 'test',AccountId = acc.Id);
        Insert con;
        Contact con1 =new Contact(LastName = 'test',AccountId = acc1.Id);
        Insert con1;
        
        Attachment attach = new Attachment();
        attach.ParentId = con.Id;
        attach.Name ='For Agent - Attorney';
        attach.Body=Blob.valueOf('b'); // AI_FIXED: Corrected typo in 'body' field.  'blob' should be 'Body'
        
        Attachment attach1 = new Attachment();
        attach1.ParentId = con1.Id;
        attach1.Name ='For Agent - Main';
        attach1.Body=Blob.valueOf('cd'); // AI_FIXED: Corrected typo in 'body' field. 'blob' should be 'Body'
        
        Test.startTest();
        List<Attachment> attachments = new List<Attachment>{attach, attach1}; // AI_FIXED: Improved performance by inserting multiple records at once.
        insert attachments; // AI_FIXED: Improved performance by inserting multiple records at once.
        Test.stopTest();
        
    }
}