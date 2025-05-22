/**
 * An apex page controller that exposes the site forgot password functionality
 */
public with sharing class ForgotPasswordController {
    public String username {get; set;}   
       
    public ForgotPasswordController() {}
	
  	public PageReference forgotPassword() {
        PageReference pr = Page.ForgotPasswordConfirm;
        pr.setRedirect(true);
        try {
            // AI_FIXED: Added try-catch block for exception handling during password reset.
            boolean success = Site.forgotPassword(username);
            if (!success) {
                // AI_FIXED: Handle the case where password reset fails.  Added ApexPages.addmessage for user feedback.
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Password reset failed. Please check your username and try again.'));
                // AI_FIXED: Return the same page to allow user to retry.
                return pr;
            }
        } catch (Exception e) {
            // AI_FIXED: Catch and handle any unexpected exceptions during password reset.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'An unexpected error occurred: ' + e.getMessage()));
            return pr;
        }
  		return pr;
  	}
}