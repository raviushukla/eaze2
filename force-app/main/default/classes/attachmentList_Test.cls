@isTest
public class attachmentList_Test {
	static testmethod void AttachmentMethod(){
        Account acc = new Account(Name = 'acctest');
        Insert acc;
        Attachment attach = new Attachment();
        attach.ParentId = acc.Id;
        attach.Name ='ClientLogo.png';
        attach.body=blob.valueof('b');
        insert attach;
        test.startTest();
        attachmentList.currentSitePrefix();
        attachmentList.fetchAttachments(acc.Id);
        attachmentList.deteteAttachment(acc.Id, attach.Id);
        test.stopTest();
    }
}