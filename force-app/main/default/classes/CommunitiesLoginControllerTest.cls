/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class CommunitiesLoginControllerTest {
    @IsTest(SeeAllData=true) 
    global static void testCommunitiesLoginController () {
     	CommunitiesLoginController controller = new CommunitiesLoginController();
        // AI_FIXED: Added try-catch block for exception handling and a more meaningful assertion.  The original assertion was not very useful.
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpCallout()); // AI_FIXED: Mocking HttpCallouts to avoid external dependencies during testing.
            PageReference pr = controller.forwardToAuthPage(); // AI_FIXED:  The return type is PageReference, not null.  This line also ensures the method is actually called.
            System.assertEquals('/secur/login.jsp', pr.getUrl()); // AI_FIXED: Asserting against a more specific and reliable value.
        } catch (Exception e){
            System.debug('Exception caught: ' + e.getMessage()); // AI_FIXED: Logging the exception for debugging purposes.
            System.assert(false, 'Unexpected exception occurred: ' + e.getMessage()); // AI_FIXED: Failing the test if an unexpected exception occurs.
        }
    }    
}

// AI_FIXED: Added a mock class for HttpCallouts.  This is crucial for testing methods that make external calls without actually making them.
@isTest global class MockHttpCallout implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/html');
        res.setBody('<html><body>Redirecting to login page</body></html>');
        res.setStatusCode(302); // AI_FIXED: Simulating a redirect response.
        return res;
    }
}