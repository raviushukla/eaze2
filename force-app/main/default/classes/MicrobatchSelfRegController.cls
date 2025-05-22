public class MicrobatchSelfRegController {
    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }

    public MicrobatchSelfRegController() {
        String expid = ApexPages.currentPage().getParameters().get('expid');
        if (expid != null) { // AI_FIXED: Changed variable name from expId to expid for consistency
            Site.setExperienceId(expid);
        }
    }

    public PageReference registerUser() {
        String userName = email;
        String accountName; 
        String contactName; 
        String profileId = 'YOUR_PROFILE_ID_HERE'; // AI_FIXED:  Assigned a default profile ID.  REPLACE 'YOUR_PROFILE_ID_HERE' with the actual ID of a suitable profile.
        String UUID;

        User u = new User();
        u.Username = userName;
        u.Email = email;
        u.FirstName = firstName;
        u.LastName = lastName;
        u.CommunityNickname = communityNickname;
        u.ProfileId = profileId;
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.Alias = userName.replace('@', '_'); // AI_FIXED: Added Alias to avoid username conflicts.  This is a simple example, adjust as needed for your org's standards.

        Account acc = new Account();
        acc.Name = 'Account for ' + lastName;
        Contact c = new Contact();
        c.LastName = lastName; // AI_FIXED: Corrected casing of lastName

        try {
            UUID =  Network.createExternalUserAsync(u, c,acc);
        } catch(Site.ExternalUserCreateException ex) {
            List<String> errors = ex.getDisplayMessages();
            for (String error : errors)  {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, error));
            }
            // AI_FIXED: Added more robust error handling.  Consider logging the exception details for debugging purposes in a production environment, but avoid exposing sensitive information to the end-user.
            System.debug('Error creating external user: ' + ex.getMessage()); // AI_FIXED: Improved debug message for clarity.
        } catch (Exception ex) { // AI_FIXED: Added a generic catch block to handle unexpected exceptions.
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'An unexpected error occurred. Please contact support.')); // AI_FIXED: Added user-friendly error message.
            System.debug('Unexpected error: ' + ex.getMessage()); // AI_FIXED: Logged unexpected error for debugging.
        }

        if (UUID != null) {
           PageReference page = System.Page.CommunitiesSelfRegConfirm;
           page.setRedirect(true);
           return page;
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'User registration failed. Please check your information and try again.')); // AI_FIXED: Added error message for failed registration.
            return null;
        }
    }
}