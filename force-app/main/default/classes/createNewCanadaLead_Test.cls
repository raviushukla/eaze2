@isTest(seeAllData=true)
public class createNewCanadaLead_Test {
    @isTest static void testClassMethod(){
        Account acc = new Account(Name='TestAccount');
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Business Account').getRecordTypeId();
        insert acc;     
        acc.Client_Code__c = 'A1B2C';
        update acc;
        //system.debug('**************** '+acc);
        createNewCanadaLead.fetchAccount(acc.Client_Code__c);
    }
    @isTest static void testClassMethod1(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 3838Name', Email='Tes783t@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        createNewCanadaLead.leadWpObj leadWrprObj = new createNewCanadaLead.leadWpObj();
        leadWrprObj.amount = '$50,000';
        leadWrprObj.salutation = 'Mr.';
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        leadWrprObj.dateBirth = '12/12/1999';
        leadWrprObj.citizenship = 'Canadian Citizen';
        leadWrprObj.state = 'ON';
        leadWrprObj.street = 'ABCD';
        leadWrprObj.city = 'QWERTY';
        leadWrprObj.zipCode = 'K0A0A2';
        leadWrprObj.residence = 'Rent';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.creditScore = 'excellent';
        leadWrprObj.monthlyRent = '$1000';
        leadWrprObj.taxIncome = '$50,000';
        leadWrprObj.expence = '$235';
        leadWrprObj.newLetter = true;
        leadWrprObj.pastBankurpty = '0';
        leadWrprObj.creditProposal = '0';
        leadWrprObj.pastBankurptyLastSeven = '0';
        leadWrprObj.agentCode = agentObj.Agent_Code__c;
        leadWrprObj.clientCode = 'KL11T';
        leadWrprObj.socialNum = 789654123;
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        createNewCanadaLead.newCanadaLead(leadWrprObj);
       	Test.stopTest();
        
    }
    
    @isTest static void testClassMethod2(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 785Name', Email='T785est@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        createNewCanadaLead.leadWpObj leadWrprObj = new createNewCanadaLead.leadWpObj();
        leadWrprObj.amount = '$50,000';
        leadWrprObj.salutation = 'Mr.';
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        leadWrprObj.dateBirth = '12/12/1999';
        leadWrprObj.citizenship = 'Canadian Citizen';
        leadWrprObj.state = 'AB';
        leadWrprObj.street = 'ABCD';
        leadWrprObj.city = 'QWERTY';
        leadWrprObj.zipCode = '123456';
        leadWrprObj.residence = 'Rent';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.creditScore = 'Good';
        leadWrprObj.monthlyRent = '$1000';
        leadWrprObj.taxIncome = '$120000';
        leadWrprObj.expence = '$2356';
        leadWrprObj.newLetter = true;
        leadWrprObj.pastBankurpty = '0';
        leadWrprObj.creditProposal = '0';
        leadWrprObj.pastBankurptyLastSeven = '0';
        leadWrprObj.agentCode = agentObj.Agent_Code__c;
        leadWrprObj.clientCode = 'KL11T';
        leadWrprObj.socialNum = 789654123;
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        Test.startTest();
        createNewCanadaLead.newCanadaLead(leadWrprObj);
        Test.stopTest();
        
    }
    
    @isTest static void testClassMethod3(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 5785Name', Email='Te5785st@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        createNewCanadaLead.leadWpObj leadWrprObj = new createNewCanadaLead.leadWpObj();
        leadWrprObj.amount = '$50,000';
        leadWrprObj.salutation = 'Mr.';
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        leadWrprObj.dateBirth = '12/12/1999';
        leadWrprObj.citizenship = 'Canadian Citizen';
        leadWrprObj.state = 'AB';
        leadWrprObj.street = 'ABCD';
        leadWrprObj.city = 'QWERTY';
        leadWrprObj.zipCode = '123456';
        leadWrprObj.residence = 'Rent';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.creditScore = 'Good';
        leadWrprObj.monthlyRent = '$1000';
        leadWrprObj.taxIncome = '$120000';
        leadWrprObj.expence = '$2356';
        leadWrprObj.newLetter = true;
        leadWrprObj.pastBankurpty = '0';
        leadWrprObj.creditProposal = '0';
        leadWrprObj.pastBankurptyLastSeven = '0';
        leadWrprObj.agentCode = agentObj.Agent_Code__c;
        leadWrprObj.clientCode = 'KL11T';
        leadWrprObj.socialNum = 789654123;
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        leadWrprObj.creditScore = 'fair';
        leadWrprObj.employment = 'Part Time';
        leadWrprObj.residence = 'Own';
        Test.startTest();
        createNewCanadaLead.newCanadaLead(leadWrprObj);
        Test.stopTest();
        
    }
    
    @isTest static void testClassMethod4(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 758Name', Email='Te757st@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        createNewCanadaLead.leadWpObj leadWrprObj = new createNewCanadaLead.leadWpObj();
        leadWrprObj.amount = '$50,000';
        leadWrprObj.salutation = 'Mr.';
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        leadWrprObj.dateBirth = '12/12/1999';
        leadWrprObj.citizenship = 'Canadian Citizen';
        leadWrprObj.state = 'AB';
        leadWrprObj.street = 'ABCD';
        leadWrprObj.city = 'QWERTY';
        leadWrprObj.zipCode = '123456';
        leadWrprObj.residence = 'Rent';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.creditScore = 'Good';
        leadWrprObj.monthlyRent = '$1000';
        leadWrprObj.taxIncome = '$120000';
        leadWrprObj.expence = '$2356';
        leadWrprObj.newLetter = true;
        leadWrprObj.pastBankurpty = '0';
        leadWrprObj.creditProposal = '0';
        leadWrprObj.pastBankurptyLastSeven = '0';
        leadWrprObj.agentCode = agentObj.Agent_Code__c;
        leadWrprObj.clientCode = 'KL11T';
        leadWrprObj.socialNum = 789654123;
        
        Test.setMock(HttpCalloutMock.class, new RestMock1());
        leadWrprObj.creditScore = 'poor';
        leadWrprObj.employment = 'Self_Employed';
        leadWrprObj.residence = '';
        Test.startTest();
        createNewCanadaLead.newCanadaLead(leadWrprObj);
       	Test.stopTest();
        
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
}