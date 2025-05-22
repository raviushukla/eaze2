@isTest
public class GetCanadaLoanConnectCsv_Test {
    
    testMethod static void method(){
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',

                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX',
                          Social_Security_Number__c = '121-322-434',
                          Loan_Connect_Client_Id__c ='1234567890');
        insert l;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        String CRON_EXP = '0 0 23 * * ?';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new getCanadaLoanConnectCsv());
        Test.stopTest();
    }
    
    public class RestMock2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('session_id,uuid,click_id,click_date,first_click_date,client_id,status'+'\n'+
                            'asdfasdf,asdfasdf,asdfasdf,asdfasdfa,"asd,fasdf",1234567890,Approved');
            response.setStatusCode(200);
            return response; 
        }
    }
    
    testMethod static void method1(){
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',
                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX',
                          Social_Security_Number__c = '121-322-434',
                          Loan_Connect_Client_Id__c ='1234567890');
        insert l;
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        String CRON_EXP = '0 0 23 * * ?';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new getCanadaLoanConnectCsv());
        Test.stopTest();
    }
    
    public class RestMock1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('Error Error ');
            response.setStatusCode(401);
            return response; 
        }
    }
    
    testMethod static void method2(){
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',
                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX',
                          Social_Security_Number__c = '121-322-434',
                          Loan_Connect_Client_Id__c ='1234567890');
        insert l;
        
        Test.setMock(HttpCalloutMock.class, new RestMock3());
        String CRON_EXP = '0 0 23 * * ?';
        Test.startTest();
        String jobId = System.schedule('ScheduledApexTest', CRON_EXP, new getCanadaLoanConnectCsv());
        Test.stopTest();
    }
    
    public class RestMock3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('session_id,uuid,click_id,click_date,first_click_date,client_id,status');
            response.setStatusCode(200);
            return response; 
        }
    }
}