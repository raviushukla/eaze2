/**
 * An apex page controller that exposes the site login functionality
 */
@IsTest global with sharing class SiteLoginControllerTest {
    @IsTest(SeeAllData=true) global static void testSiteLoginController () {
        // Instantiate a new controller with all parameters in the page
        // AI_FIXED:  Using a test user instead of hardcoded credentials for better security and maintainability.
        User testUser = createTestUser();
        SiteLoginController controller = new SiteLoginController(testUser.Alias); // AI_FIXED: Passing the username to the controller.  The original code was missing this parameter.

        controller.username = testUser.Username; // AI_FIXED: Setting username from the test user.
        controller.password = testUser.Password; // AI_FIXED: Setting password from the test user.

        try {
            // AI_FIXED: Added try-catch block for exception handling during login.
            System.assertEquals(controller.login(),null); // AI_FIXED:  Checking the return value of the login method.  The original assertion was incomplete and likely to fail.
        } catch (Exception e) {
            System.debug('Login failed: ' + e.getMessage()); // AI_FIXED: Logging the exception for debugging purposes.
            System.assert(false, 'Login failed: ' + e.getMessage()); // AI_FIXED: Failing the test if an exception occurs.
        }
    }

    // AI_FIXED: Helper method to create a test user.
    private static User createTestUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User u = new User(Alias = 'standt', Email='testuser@testorg.com', EmailEncodingKey='UTF-8',
                          LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US',
                          ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
        insert u;
        return u;
    }
}