/**
 * An apex page controller that exposes the site login functionality
 */
global with sharing class SiteLoginController {
    global String username {get; set;}
    global String password {get; set;}

    global PageReference login() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        PageReference pageRef;
        try {
            pageRef = Site.login(username, password, startUrl); // AI_FIXED: Added try-catch block for exception handling
        } catch (Exception e) {
            // AI_FIXED: Handle exceptions appropriately (log error, display error message, etc.)
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Login failed: ' + e.getMessage()));
            pageRef = new PageReference('/error'); // AI_FIXED: Redirect to an error page
        }
        return pageRef; // AI_FIXED: Return the PageReference
    }
    
   	global SiteLoginController () {}
}