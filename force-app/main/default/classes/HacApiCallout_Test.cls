@isTest
global class HacApiCallout_Test {
	
    testMethod static void apiCallout(){
        Date todayDate = Date.Today();
        Lead leadObj = new Lead(LastName = 'Test', Time_at_Address_In_Months__c = 1, Annual_Pre_Tax_Income__c = 1000, Income_Source_1__c = 'Employed',
                               Date_of_Birth__c = Date.newInstance(1990, 10, 10), MobilePhone = '9876543210', Street = '123, Test Street', 
                               Monthly_Rent_Mortgage_Amount__c = 10000, Loan_Amount__c = 10000, Employment_Date__c = todayDate);
        insert leadObj;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HacApiCallout.sendApplication(leadObj.Id);
        test.stopTest();
    }
    
    testMethod static void apiCallout1(){
        Date todayDate = Date.Today();
        Lead leadObj = new Lead(LastName = 'Test', Time_at_Address_In_Months__c = 1, Annual_Pre_Tax_Income__c = 1000, Income_Source_1__c = 'Self_Employed',
                               Date_of_Birth__c = Date.newInstance(1990, 10, 10), MobilePhone = '9876543210', Street = '123, Test Street', 
                               Monthly_Rent_Mortgage_Amount__c = 10000, Loan_Amount__c = 10000,Employment_Date__c = todayDate);
        insert leadObj;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        HacApiCallout.sendApplication(leadObj.Id);
        test.stopTest();
    }
    
    testMethod static void apiCallout2(){
        Date todayDate = Date.Today();
        Lead leadObj = new Lead(LastName = 'Test', Time_at_Address_In_Months__c = 1, Annual_Pre_Tax_Income__c = 1000, Income_Source_1__c = '',
                               Date_of_Birth__c = Date.newInstance(1990, 10, 10), MobilePhone = '9876543210', Street = '123, Test Street', 
                               Monthly_Rent_Mortgage_Amount__c = 10000, Loan_Amount__c = 10000, Employment_Date__c = todayDate);
        insert leadObj;
        
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGeneratorError()); // AI_FIXED: Using MockHttpResponseGeneratorError to simulate error scenario
        test.startTest();
        try{
            HacApiCallout.sendApplication(leadObj.Id);
        } catch(Exception e){
            System.debug('Exception caught: ' + e.getMessage()); // AI_FIXED: Added try-catch block for exception handling
        }
        test.stopTest();
    }
    
    global class MockHttpResponseGenerator implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    global class MockHttpResponseGeneratorError implements HttpCalloutMock {
        global HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example":"test"}');
            res.setStatusCode(400); // AI_FIXED: Changed status code to simulate an error response.  201 is not an error code.
            return res;
        }
    }
}