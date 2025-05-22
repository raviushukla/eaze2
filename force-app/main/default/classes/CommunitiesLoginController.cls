/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class CommunitiesLoginController {

    global CommunitiesLoginController () {}
    
    // Code we will invoke on page load.
    global PageReference forwardToAuthPage() {
    	String startUrl = System.currentPageReference().getParameters().get('startURL');
        String displayType = System.currentPageReference().getParameters().get('display');
        // AI_FIXED: Added null checks for startUrl and displayType to prevent NullPointerExceptions
        if (startUrl == null) {
            startUrl = ''; // AI_FIXED: Assign empty string if startUrl is null
        }
        if (displayType == null) {
            displayType = ''; // AI_FIXED: Assign empty string if displayType is null
        }
        try {
            return Network.forwardToAuthPage(startUrl, displayType);
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to gracefully handle errors during authentication
            System.debug('Error during authentication: ' + e.getMessage());
            return new PageReference('/error'); // AI_FIXED: Redirect to an error page
        }
    }
}