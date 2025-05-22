@isTest
global class LeadPreQualificationApex_Test {

    global class EchoHttpMockPreQualSuccess implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String strbody = ('YmxQazVVN3JBeElyVlNTaVhBRlNwZz09'); 
            res.setBody(strbody);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
    public Static testMethod void preQualSuccessCase(){
        lead led = new lead();
        led.Loan_Amount__c = 5678;
        led.Status = 'New Lead';
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OEA Application'; 
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Email = 'abc@gmail.com';
        led.MobilePhone = '9255007723';
        led.ErrorLog__c = 'error';
        led.Street = 'United States';
        led.city = 'Hoover';
        led.state = 'AL';
        led.PostalCode = 'dsdsd';
        insert led;
        
        Test.setMock(HttpCalloutMock.class, new EchoHttpMockPreQualSuccess());
        Test.startTest();
        LeadPreQualificationApex.LeadPreQualificationPost(led.Id);
        Test.stopTest();
    }
    
    global class EchoHttpMockPreQualError1 implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String strbody = ('please complete each of the required fields.'); 
            res.setBody(strbody);
            res.setStatusCode(404);
            res.setStatus('NOT FOUND');
            return res;
        }
    }
    public Static testMethod void preQualErrorCase1(){
        lead led = new lead();
        led.Loan_Amount__c = 5678;
        led.Status = 'New Lead';
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OEA Application'; 
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Email = 'abc@gmail.com';
        led.MobilePhone = '9255007723';
        led.Street = 'United States';
        led.city = 'Hoover';
        led.state = 'AL';
        led.PostalCode = 'dsdsd';
        insert led;
        
        Test.setMock(HttpCalloutMock.class, new EchoHttpMockPreQualError1());
        Test.startTest();
        LeadPreQualificationApex.LeadPreQualificationPost(led.Id);
        Test.stopTest();
    }
    
    global class EchoHttpMockPreQualError2 implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String strbody = ('please complete each of the required fields.'); 
            res.setBody(strbody);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
    public Static testMethod void preQualErrorCase2(){
        lead led = new lead();
        led.Loan_Amount__c = 5678;
        led.Status = 'New Lead';
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OEA Application'; 
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Email = 'abc@gmail.com';
        led.MobilePhone = '9255007723';
        led.Street = 'United States';
        led.city = 'Hoover';
        led.state = 'AL';
        led.PostalCode = 'dsdsd';
        insert led;
        
        Test.setMock(HttpCalloutMock.class, new EchoHttpMockPreQualError2());
        Test.startTest();
        LeadPreQualificationApex.LeadPreQualificationPost(led.Id);
        Test.stopTest();
    }
    public Static testMethod void preQualErrorCase3(){
        lead led = new lead();
        led.Loan_Amount__c = 5678;
        led.Status = 'New Lead';
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OEA Application'; 
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Email = 'abc@gmail.com';
        led.MobilePhone = '9255007723';
        led.Street = 'United States';
        led.city = '';
        led.state = '';
        led.PostalCode = 'dsdsd';
        insert led;
        
        Test.startTest();
        LeadPreQualificationApex.LeadPreQualificationPost(led.Id);
        Test.stopTest();
    }
    
    
}