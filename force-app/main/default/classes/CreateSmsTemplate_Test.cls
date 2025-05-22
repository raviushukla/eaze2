@isTest
public class CreateSmsTemplate_Test {
    public static testmethod void forFetchingsObjects(){
        Test.startTest();
        List<String> objlist = CreateSmsTemplate.fetchsObjects();
        Test.stopTest();
    }
    public static testmethod void getFields(){
        Test.startTest();
        List<string> getfieldList = CreateSmsTemplate.getsObjectFields('Contact');
        Test.stopTest();
    }
    public static testmethod void getLookUp(){
        Test.startTest();
        CreateSmsTemplate.getLookUpfields('Accountid', 'Contact');
        CreateSmsTemplate.getLookUpfields('name', 'Contact');
        Test.stopTest();
    }
    public static testmethod void saveTemplate(){
        Test.startTest();
        String  sms = CreateSmsTemplate.saveRecordDetails('TestclassSms', 'Test','hi SmsAccount', 'Contact','');
        Test.stopTest();
    }
    public static testmethod void onSecondClick(){
        Test.startTest();
        List<String> objlist1 = CreateSmsTemplate.getSecondclick();
        Test.stopTest();
    }
    public static testmethod void editTemplate(){
        Sms_Template__c sms = new Sms_Template__c();
        sms.Name = 'TestByClass';
        sms.SMS_Text__c = 'Hello {{Lead.owner.name}} {{lead.name}} ';
        sms.Subject__c = 'Test';
        sms.Parent__c = 'Lead';
        insert sms;
        String tempId = sms.Id;
        system.assert(tempId != null);
        Test.startTest();
        Sms_Template__c st = CreateSmsTemplate.editTemplate(tempId);
        
        Test.stopTest();
    }
}