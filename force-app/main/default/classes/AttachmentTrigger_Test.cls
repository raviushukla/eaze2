@isTest
public class AttachmentTrigger_Test {
    @istest static void AttachmentMethod(){
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
        attach.body=blob.valueof('b');
        
        Attachment attach1 = new Attachment();
        attach1.ParentId = con1.Id;
        attach1.Name ='For Agent - Main';
        attach1.body=blob.valueof('cd');
        
        Test.startTest();
        Insert attach;
        Insert attach1;
        Test.stopTest();
        
    }
}