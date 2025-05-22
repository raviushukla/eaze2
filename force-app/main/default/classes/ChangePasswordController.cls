/**
 * An apex page controller that exposes the change password functionality
 */
public with sharing class ChangePasswordController {
    public String oldPassword {get; set;}
    public String newPassword {get; set;}
    public String verifyNewPassword {get; set;}        
    
    public PageReference changePassword() {
        PageReference pageRef = null;
        try {
            // AI_FIXED: Added try-catch block for exception handling
            if(newPassword == verifyNewPassword){
                pageRef = Site.changePassword(oldPassword, newPassword, verifyNewPassword); // AI_FIXED: Corrected parameter order in Site.changePassword method
            } else {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'New Password and Verify Password do not match')); // AI_FIXED: Added error message if passwords don't match.
            }
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to catch potential errors during password change.
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'An error occurred: ' + e.getMessage()));
        }
        return pageRef; // AI_FIXED: Return pageRef instead of directly returning Site.changePassword
    }     
    
   	public ChangePasswordController() {}
}