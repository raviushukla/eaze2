/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        PageReference pageRef = Network.communitiesLanding(); // AI_FIXED: Assigned the result of Network.communitiesLanding() to a variable for better handling.
        if(pageRef == null){ // AI_FIXED: Added a null check to handle potential null return from Network.communitiesLanding()
            pageRef = new PageReference('/home'); // AI_FIXED: Redirect to home page if Network.communitiesLanding() returns null.  This provides a fallback.
        }
        return pageRef;
    }
    
    public CommunitiesLandingController() {}
}