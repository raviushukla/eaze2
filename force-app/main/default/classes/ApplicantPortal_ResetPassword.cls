public without sharing class ApplicantPortal_ResetPassword {
    @AuraEnabled
    public static string sessionCheck(String sessionId){
        // AI_FIXED: Added null check for sessionId
        if(sessionId == null) return '';

        List<Login_Session__c>  ls = [SELECT Id 
                                      From Login_Session__c 
                                      Where Session_Id__c = :sessionId // AI_FIXED: Using bind variable to prevent SOQL injection
                                      AND Type__c = 'Applicant Reset Password'
                                      AND Expired__c = false Limit 1];
        system.debug('ls'+ls);
        //allowelse login
        if(ls.size()==1){
            return 'success';
        }
        return '';
    }
	@AuraEnabled
    public static String updatePassword(String newPass, String sessionId) {
        String result = '';
        // AI_FIXED: Added null checks for newPass and sessionId
        if(newPass == null || sessionId == null) return 'Error: Invalid parameters';

        try{
            if(newPass.length() >= 8 && newPass.length() <= 15){
                List<Login_Session__c>  ls = [SELECT Expired__c, Lead__c 
                                              From Login_Session__c 
                                              Where Session_Id__c = :sessionId // AI_FIXED: Using bind variable to prevent SOQL injection
                                              AND Type__c = 'Applicant Reset Password'
                                              AND Expired__c = false Limit 1];
                system.debug('ls'+ls);
                //allowelse login
                if(ls.size()==1){
                    Lead leadObj = new Lead(Id=ls[0].Lead__c, CAN_Password__c=newPass);
                    update leadObj;
                    ls[0].Expired__c = true;
                    update ls;
                    result = 'success';
                } else {
                    // AI_FIXED: Handle case where session is not found
                    result = 'Error: Invalid session ID';
                }
            } else {
                // AI_FIXED: Handle case where password length is invalid
                result = 'Error: Password must be between 8 and 15 characters';
            }
        }
        catch(Exception ex){
            // AI_FIXED: Improved error message
            result = 'Error: ' + ex.getMessage() + ' Stack Trace: ' + ex.getStackTraceString();
        }
        return result;
    }
}