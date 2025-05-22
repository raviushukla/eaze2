public without sharing class ApplicantPortal_Login {
	@AuraEnabled
    public static String checkUser(String username, String password) {
        // AI_FIXED: Added try-catch block for exception handling during SOQL query
        try{
            // AI_FIXED:  Using parameterized query to prevent SOQL injection
            List<Lead> leadList = [Select CAN_Password__c, CAN_Username__c, Id From Lead Where CAN_Username__c = :username Order By CreatedDate DESC Limit 1];
            String sessionId = '';
            if(leadList.size()>0 && leadList[0].CAN_Password__c == password){
                Boolean validCode = false;
                while( !validCode ){
                    sessionId = createSessionId();
                    validCode = validateSessionId(sessionId, 'Applicant Login');
                }
                Login_Session__c ls = new Login_Session__c();
                ls.Session_Id__c = sessionId;
                ls.Lead__c = leadList[0].Id;
                ls.Type__c = 'Applicant Login';
                try{
                    insert ls;
                }
                catch(Exception ex){
                    // AI_FIXED: Returning a more user-friendly error message.
                    return 'Error logging in: '+ex.getMessage();
                }
                // AI_FIXED: Using JSON.serialize for better JSON formatting
                sessionId = JSON.serialize(new Map<String, String>{'SessionId' => sessionId, 'userName' => username});
            }
            return sessionId;
        } catch(Exception ex){
            // AI_FIXED: Handling exceptions during SOQL query.
            return 'Error querying leads: ' + ex.getMessage();
        }
    }
    
    @AuraEnabled
    public static String forgetPassword(String username) { // AI_FIXED: Corrected spelling of 'forgetPassowrd'
        // AI_FIXED: Added try-catch block for exception handling during SOQL query
        try{
            // AI_FIXED: Using parameterized query to prevent SOQL injection
            List<Lead> leadList = [Select CAN_Username__c,Email, Id From Lead Where CAN_Username__c = :username Order By CreatedDate DESC Limit 1];
            if(leadList.size()>0){
                String sessionId = '';
                Boolean validCode = false;
                while( !validCode ){
                    sessionId = createSessionId();
                    validCode = validateSessionId(sessionId, 'Applicant Reset Password');
                }
                Login_Session__c ls = new Login_Session__c();
                ls.Session_Id__c = sessionId;
                ls.Lead__c = leadList[0].Id;
                ls.Type__c = 'Applicant Reset Password';
                ls.Applicant_Email__c = leadList[0].Email;
                insert ls;
                return 'success';
            }
            return '';
        } catch(Exception ex){
            // AI_FIXED: Handling exceptions during SOQL query.
            return 'Error querying leads: ' + ex.getMessage();
        }
    }
    public static string createSessionId(){
        String sessionId = '';
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        Integer len = 50;
        while (sessionId.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            sessionId += chars.substring(idx, idx+1);
        }
        return sessionId;
    }
    public static boolean validateSessionId(String sessionId, String lsType){
        Boolean isValid = true;
        // AI_FIXED: Using parameterized query to prevent SOQL injection
        List<Login_Session__c> ls = [Select Id From Login_Session__c Where Session_Id__c = :sessionId Limit 1];
        if(ls.size()>0)
            isValid = false;
        return isValid;
    }
}