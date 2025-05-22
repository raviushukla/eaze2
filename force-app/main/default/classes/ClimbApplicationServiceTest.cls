@isTest
private class ClimbApplicationServiceTest {
    @TestSetup
    static void setup() {
        // Create test Account with Climb Credit School ID
        Account testAccount = new Account(
            Name = 'Test School',
            Climb_Credit_School_ID__c = 'MA9433669919215'
        );
        insert testAccount;

        // Create test Lead
        Lead testLead = new Lead(
            FirstName = 'John',
            LastName = 'Doe',
            Email = 'john.doe@test.com',
            MobilePhone = '1234567890',
            Street = '123 Test St',
            City = 'Test City',
            State = 'CA',
            PostalCode = '12345',
            Company = 'Test Company',
            Account__c = testAccount.Id
        );
        insert testLead;
    }

    @isTest
    static void testSuccessfulApplicationLinkGeneration() {
        // Get the test lead
        Lead testLead = [SELECT Id, Email FROM Lead LIMIT 1];
        
        // Create test input
        ClimbApplicationService.FlowInput input = new ClimbApplicationService.FlowInput();
        input.leadEmail = testLead.Email;
        List<ClimbApplicationService.FlowInput> inputList = new List<ClimbApplicationService.FlowInput>{input};

        // Mock HTTP response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start test execution
        Test.startTest();
        List<ClimbApplicationService.FlowOutput> result = ClimbApplicationService.initiateLoanApp(inputList);
        Test.stopTest();

        // Verify results
        System.assertEquals(1, result.size(), 'Should return one output');
        System.assertNotEquals(null, result[0].applicationLink, 'Application link should not be null');
        System.assert(!result[0].applicationLink.startsWith('Error'), 'Should not return an error message');
        
        // Verify lead was updated
        Lead updatedLead = [SELECT Climb_Credit_Application_Link__c FROM Lead WHERE Id = :testLead.Id];
        System.assertNotEquals(null, updatedLead.Climb_Credit_Application_Link__c, 'Lead should have application link');
    }

    @isTest
    static void testErrorHandling() {
        // Get the test lead
        Lead testLead = [SELECT Id, Email FROM Lead LIMIT 1];
        
        // Create test input
        ClimbApplicationService.FlowInput input = new ClimbApplicationService.FlowInput();
        input.leadEmail = testLead.Email;
        List<ClimbApplicationService.FlowInput> inputList = new List<ClimbApplicationService.FlowInput>{input};

        // Mock HTTP response with error
        Test.setMock(HttpCalloutMock.class, new MockHttpErrorResponseGenerator());

        // Start test execution
        Test.startTest();
        List<ClimbApplicationService.FlowOutput> result = ClimbApplicationService.initiateLoanApp(inputList);
        Test.stopTest();

        // Verify error handling
        System.assertEquals(1, result.size(), 'Should return one output');
        System.assert(result[0].applicationLink.startsWith('Error'), 'Should return an error message');
    }

    @isTest
    static void testExceptionHandling() {
        // Get the test lead
        Lead testLead = [SELECT Id, Email FROM Lead LIMIT 1];
        
        // Create test input
        ClimbApplicationService.FlowInput input = new ClimbApplicationService.FlowInput();
        input.leadEmail = testLead.Email;
        List<ClimbApplicationService.FlowInput> inputList = new List<ClimbApplicationService.FlowInput>{input};

        // Mock HTTP response that throws exception
        Test.setMock(HttpCalloutMock.class, new MockHttpExceptionGenerator());

        // Start test execution
        Test.startTest();
        List<ClimbApplicationService.FlowOutput> result = ClimbApplicationService.initiateLoanApp(inputList);
        Test.stopTest();

        // Verify exception handling
        System.assertEquals(1, result.size(), 'Should return one output');
        System.assert(result[0].applicationLink.startsWith('Error'), 'Should return an exception message');
    }

    // Mock HTTP response generator for successful response
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"url": "https://test.climbcredit.com/application/12345"}');
            res.setStatusCode(200);
            return res;
        }
    }

    // Mock HTTP response generator for error response
    private class MockHttpErrorResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"error": "Invalid request"}');
            res.setStatusCode(400);
            return res;
        }
    }

    // Mock HTTP response generator that throws exception
    private class MockHttpExceptionGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            throw new CalloutException('Test exception');
        }
    }
}