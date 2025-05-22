@isTest
global class PayPossibbleHelper_Test {
    global Static testMethod void testdataToken(){
        list<Id> listId = new list<Id>();
        lead led = new lead();
        led.Loan_Amount__c = 5678;
        led.Status = 'New Lead';
        led.Credit_Score__c = 720;
        led.agree__c = true;
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OEA Application'; 
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Email = 'abc@gmail.com';
        led.MobilePhone = '9255007723';
        led.ErrorLog__c = 'error';
        led.Current_Residence_Type__c =  'Apartment';
        led.Street = 'United States';
        led.city = 'Hoover';
        led.state = 'AL';
        led.PostalCode = 'dsdsd';
        led.ErrorLog__c = '';
        led.Time_at_Address_In_Months__c = 12;
        led.Current_Residence_Status__c = 'Buying';
        led.Income_Source_1__c = 'military';
        led.Position__c = 'developer';
        led.Hire_Date__c = system.today();
        led.Current_Employer__c = 'WNC';
        led.Annual_Pre_Tax_Income__c = 50000;
        led.Payroll_Frequency__c = 'biweekly';
        led.Payroll_Type__c = 'cash';
        led.Credit_Score_Text__c = 'good';
        insert led;
        listId.add(led.id);
        Test.setMock(HttpCalloutMock.class, new CreatePPLeadMock());
        Test.startTest();
        PayPossibleHelper.sendLeadToPayPossibleFuture(led.Id);
        SendToPayPossibleHelper.sendLeadToPayPossible(listId);
        Test.stopTest();
    }
    
    global Static testMethod void testDataLeadCreate(){
        lead led = new lead();
        led.Loan_Amount__c = 5678;
        led.Status = 'New Lead';
        led.Credit_Score__c = 720;
        led.agree__c = true;
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OEA Application'; 
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Email = 'abc@gmail.com';
        led.MobilePhone = '9255007723';
        led.ErrorLog__c = 'error';
        led.Current_Residence_Type__c =  'Apartment';
        led.Street = 'United States';
        led.city = 'Hoover';
        led.state = 'AL';
        led.PostalCode = 'dsdsd';
        led.ErrorLog__c = '';
        led.Time_at_Address_In_Months__c = 12;
        led.Current_Residence_Status__c = 'Buying';
        led.Income_Source_1__c = 'military';
        led.Position__c = 'developer';
        led.Hire_Date__c = system.today();
        led.Current_Employer__c = 'WNC';
        led.Annual_Pre_Tax_Income__c = 50000;
        led.Payroll_Frequency__c = 'biweekly';
        led.Payroll_Type__c = 'cash';
        led.Credit_Score_Text__c = 'good';
        insert led;
        
        Test.setMock(HttpCalloutMock.class, new EchoHttpMockleadcreate());
        Test.startTest();
        PayPossibleHelper.sendLeadToPayPossibleFuture(led.Id);
        Test.stopTest();
    }
    
    global Static testMethod void testLeadDataPingGet(){
        list<lead> listLead = new list<lead>();
        lead led1 = new lead();
        led1.Loan_Amount__c = 5678;
        led1.Status = 'Send to Pay Possible';
        led1.Credit_Score__c = 720;
        led1.agree__c = true;
        led1.FirstName = 'test';
        led1.LeadSource = 'OEA Application';
        led1.lastname = 'kumar';
        led1.ErrorLog__c = 'error';
        led1.Date_of_Birth__c = system.today();
        led1.Credit_Score_Text__c = 'poor';
        led1.Social_Security_Number__c = '123456789';
        led1.Pay_Possible_lead_ID__c = 'ced1fc81-7413-4dcc-8dcc-654410c463e4';
        led1.Email = 'abc@gmail.com';
        led1.MobilePhone = '9255007723';
        led1.Street = 'United States';
        led1.Current_Residence_Type__c =  'Apartment';
        led1.city = 'Hoover';
        led1.state = 'AL';
        led1.ErrorLog__c = 'error';
        led1.Time_at_Address_In_Months__c = 12;
        led1.Pay_Possible_Pinged__c = true;
        led1.Current_Residence_Status__c = 'Buying';
        led1.Income_Source_1__c = 'military';
        led1.Pay_Possible_Status__c = 'pending';
        led1.Position__c = 'developer';
        led1.Hire_Date__c = system.today();
        led1.Pay_Possible_Ping_Count__c = 1;
        led1.Current_Employer__c = 'WNC';
        led1.Annual_Pre_Tax_Income__c = 18000;
        led1.Payroll_Frequency__c = 'BiWeekly';
        led1.Payroll_Type__c = '';
        listLead.add(led1);
        insert listLead;
        
        list<id> lid = new list<id>();
        lead lds = new lead();
        String strLeadId = '';
        for(lead ld:listLead){
            lds = ld; 
            lid.add(ld.id);
            strLeadId = ld.id;
        }
        
        Test.setMock(HttpCalloutMock.class, new EchoHttpMockleadcreate());
        Test.startTest();
        String str = 'J0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjo0NjMxLCJ1c2VybmFtZSI6InNic3BhcnRuZXIiLCJleHAiOjE1NTM4NDE1OTAsImVtYWlsIjoiaW5mb0BzYnNmaW5hbmNpbmcuY29tIiwib3JpZ19pYXQiOjE1NTM4NDEyOTB9.id4mk9GIwpXSnvT4DUUecKXGPpIyJdslFAlPZcINjEg';
        String Responsebod = ('{"offers":[{"id":"098465473","amount":"$20,0000","apply_url":"https://cs30.salesforce.com","apr":"123.90%","monthly_payment":"$2,000","originator":{"name":"rahul","description":"hello how are you","disclaimer":"idontno","image":"https://cs30.salesforce.com","email":"abc@gmail.com","phone":"9255007723","website":"https://cs30.salesforce.com"},"term":"plan","terms":"plans","date_created":"2019-03-29T00:00:00.000Z","date_updated":"2019-03-29T00:00:00.000Z"}]}');
        string str1= 'pinged';
        PayPossibleHelper.leadPing(str,led1);
        PayPossibleWebServiceClass.sendLeadToPayPossible(strLeadId);
        PayPossibleWebServiceClass.getOfferFromPayPossible(strLeadId);
        Test.stopTest();
    }
    
    global class CreatePPLeadMock implements HttpCalloutMock {
        global HTTPResponse respond( HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String strbody = '{"id":"sdsd","status":"pending"}';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(strbody);
            res.setStatusCode(201);
            res.setStatus('Created');
            return res;
        }
    }
    
    global class EchoHttpMockleadcreate implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            String strbody = ('{"id":"sdsd","status":"pending","offers":[{"id":"098465473","amount":"$20,0000","apply_url":"https://cs30.salesforce.com","apr":"12.70%","monthly_payment":"$2,000","originator":{"name":"rahul","description":"hello how are you","disclaimer":"idontno","image":"https://cs30.salesforce.com","email":"abc@gmail.com","phone":"9255007723","website":"https://cs30.salesforce.com"},"term":"plan","terms":"plans","date_created":"2019-03-29T00:00:00.000Z","date_updated":"2019-03-29T00:00:00.000Z"}]}'); 
            res.setHeader('Content-Type', 'application/json');
            res.setBody(strbody);
            res.setStatusCode(200);
            return res;
        }
    }
}