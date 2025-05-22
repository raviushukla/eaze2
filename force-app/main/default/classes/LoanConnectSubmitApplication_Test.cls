@isTest()
public class LoanConnectSubmitApplication_Test {
    @isTest() static void SummitLoanApplicationTest1(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
		
		Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];		
        
        Lead newLead = new Lead();
        newLead.Status = 'New Lead';
        newLead.FirstName = 'Test';
        newLead.LastName = 'Lead 1';
        newLead.Loan_Amount__c = 15000;
        newLead.Current_Residence_Status__c = 'Rent';
        newLead.Credit_Score__c = 700;
        newLead.City = 'Toranto';
        newLead.Street = 'Canada Street';
        newLead.State = 'AB';
        newLead.Monthly_Gross_Income__c = 55000;
        newLead.Date_of_Birth__c = Date.newInstance(1999, 03, 29);
        newLead.Email = 'Test@gmail.com';
        newLead.Income_Source_1__c = 'Employed';
        newLead.PostalCode = 'V2X6M2';
        newLead.MobilePhone = '9871254243';
        newLead.Credit_Score_Text__c = 'excellent';
        newLead.Monthly_Rent_Mortgage_Amount__c = 10000;
        newLead.Account__c = client.Id;
        newLead.Agent_Code__c = agentObj.Agent_Code__c;
        newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId();
        newLead.Source_URL__c = 'test';
        newLead.CurrencyIsoCode = 'CAD';
        newLead.Purpose__c = 'Purchase an Item';
        newLead.Social_Security_Number__c = String.valueOf(321654987);
        newLead.Credit_Proposal__c = true;
        newLead.Past_Bankruptcy_Last_7_Years__c = false;
        INSERT newLead;
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        TEST.startTest();
        LoanConnectSubmitApplication.SubmitLoanApplication(newLead.Id);
        TEST.stopTest();
    }
    
    @isTest() static void SummitLoanApplicationTest2(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        Lead newLead = new Lead();
        newLead.Status = 'New Lead';
        newLead.FirstName = 'Test';
        newLead.LastName = 'Lead 2';
        newLead.Loan_Amount__c = 15000;
        newLead.Current_Residence_Status__c = 'Rent';
        newLead.Credit_Score__c = 700;
        newLead.City = 'Toranto';
        newLead.Street = 'Canada Street';
        newLead.State = 'ABC';
        newLead.Monthly_Gross_Income__c = 55000;
        newLead.Date_of_Birth__c = Date.newInstance(1999, 03, 29);
        newLead.Email = 'Test@gmail.com';
        newLead.Income_Source_1__c = 'Employed';
        newLead.PostalCode = 'V2X6M';
        newLead.MobilePhone = '9871254243';
        newLead.Credit_Score_Text__c = 'excellent';
        newLead.Monthly_Rent_Mortgage_Amount__c = 10000;
        newLead.Account__c = client.Id;
        newLead.Agent_Code__c = agentObj.Agent_Code__c;
        newLead.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('CAN Lead').getRecordTypeId();
        newLead.Source_URL__c = 'test';
        newLead.CurrencyIsoCode = 'CAD';
        newLead.Purpose__c = 'Purchase an Item';
        newLead.Social_Security_Number__c = String.valueOf(321654987);
        newLead.Credit_Proposal__c = true;
        newLead.Past_Bankruptcy_Last_7_Years__c = false;
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        INSERT newLead;
        TEST.startTest();
        LoanConnectSubmitApplication.SubmitLoanApplication(newLead.Id);
        TEST.stopTest();
    }
    private class RestMock1 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            String respn = '{ "isError": true, "error": "", "status": false, "userStatus": 0,'+ 
                                '"messages": [{"pc": ["pc (postal code) is required"],'+
                				'"province": ["province is required or does not pass validation (two-letter abbreviation)" ]}],'+
                                    '"meta": [],"result": [],"data": [],"timestamp": "2022-07-19T07:43:10+00:00"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(respn);
            res.setStatusCode(400);
            return res;
        }
    }
    private class RestMock2 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            String respn = '{"isError": false,"error": "","status": false,"userStatus": 2,"messages": "", "meta": [],'+
                             '"result": [{"amount": "40000","apr_range_high": "","apr_range_low": "15","company_type": "lender",'+
                                          '"has_applied": false,"lender_logo": "https://sandbox.loanconnect.ca/img/1553024122FAF-logo-new-1024x285[1]__scaled_225_100.png",'+
                                          '"lender_name": "FastAccess","monthly_payment_range_high": 0,"monthly_payment_range_low": 1386.61,'+
                                          '"preapproved": true,'+
                                          '"select_url": "https://sandbox.loanconnect.ca/api/makeWebRequestjson/5pN2zi647InJTIoV9w3hSt0bDsVdXMgM2_wZIfzoxVA/3kPGxMo6kUgsbjreOmupp8RQd_xF3MWP0ivervNgbgI/40000",'+
                                          '"term": "36"}],'+
                                          '"data": [],"timestamp": "2022-07-15T10:15:36+00:00",'+
                                          '"client_id": "3kPGxMo6kUgsbjreOmupp8RQd_xF3MWP0ivervNgbgI"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(respn);
            res.setStatusCode(200);
            return res;
        }
    }
}