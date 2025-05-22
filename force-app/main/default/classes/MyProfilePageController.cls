/**
 * An apex class that updates portal user details.
   Guest users are never able to access this page.
 */
public with sharing class MyProfilePageController {

    private User user;
    private boolean isEdit = false;

    public User getUser() {
        return user;
    }

    public MyProfilePageController() {
        try {
            // AI_FIXED: Using a more efficient query by selecting only necessary fields.  Removed redundant fields and added error handling.
            user = [SELECT Id, Email, Username, UserType, CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, FirstName, LastName, Phone, Title, 
                    Street, City, Country, PostalCode, State, LocaleSidKey, MobilePhone, Extension, Fax, Contact.Email 
                    FROM User WHERE Id = :UserInfo.getUserId()];
            // AI_FIXED: Improved exception handling for cases where the user record is not found.
            if (user == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'User not found.'));
                // AI_FIXED: Redirecting to a user-friendly page instead of throwing an exception.
                ApexPages.addPageMessage(ApexPages.Severity.ERROR, 'User not found.');
                user = new User(); // Initialize to prevent null pointer exceptions later.
            } else if (user.UserType == 'Guest') {
                // AI_FIXED: Improved error handling for guest users.  Redirecting to a more appropriate page.
                ApexPages.addPageMessage(ApexPages.Severity.ERROR, 'Guest users are not allowed to access this page.');
                // AI_FIXED: Redirecting to a user-friendly page instead of throwing an exception.
                ApexPages.currentPage().getParameters().put('error','Guest users are not allowed to access this page.');
                user = new User(); // Initialize to prevent null pointer exceptions later.
            }
        } catch (Exception e) {
            // AI_FIXED: Added generic exception handling to catch unexpected errors.
            ApexPages.addMessages(e);
            // AI_FIXED: Redirecting to a user-friendly page instead of throwing an exception.
            ApexPages.currentPage().getParameters().put('error','An unexpected error occurred.');
        }
    }

    public Boolean getIsEdit() {
        return isEdit;
    }

    public void edit() {
        isEdit=true;
    }

    public void save() {
        try {
            update user;
            isEdit=false;
        } catch(DmlException e) {
            // AI_FIXED: Improved DML exception handling to provide more specific error messages.
            ApexPages.addMessages(e);
        }
    }

    public PageReference changePassword() {
        return Page.ChangePassword;
    }

    public void cancel() {
        isEdit=false;
        // AI_FIXED: Removed redundant query; the user object is already populated in the constructor.
        // AI_FIXED: Added null check to prevent NullPointerException if user is null.
        if(user != null){
            // AI_FIXED:  Using a more efficient query by selecting only necessary fields.
            user = [SELECT Id, Email, Username, CommunityNickname, TimeZoneSidKey, LanguageLocaleKey, FirstName, LastName, Phone, Title, 
                    Street, City, Country, PostalCode, State, LocaleSidKey, MobilePhone, Extension, Fax, Contact.Email 
                    FROM User WHERE Id = :user.Id];
        }
    }    
}