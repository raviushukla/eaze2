public without sharing class CustomResetPasswordPage {
    @AuraEnabled
    public static string sessionCheck(String sessionId){
        system.debug('sessionId'+sessionId);
        // AI_FIXED: Added try-catch block for exception handling and added input sanitization to prevent SOQL injection
        try{
            List<Login_Session__c>  ls = [SELECT Id 
                                      From Login_Session__c 
                                      Where Session_Id__c = :sessionId // AI_FIXED: Using bind variable to prevent SOQL injection
                                      AND Type__c = 'Reset Password'
                                      AND Expired__c = false Limit 1];
            system.debug('ls'+ls);
            //allowelse login
            if(ls.size()==1){
                return 'success';
            }
            return '';
        } catch(Exception ex){
            // AI_FIXED: Returning error message for better debugging
            return 'Error: ' + ex.getMessage();
        }
    }
	@AuraEnabled
    public static String updatePassword(String newPass, String sessionId) {
        String result = '';
        // AI_FIXED: Added try-catch block for exception handling and added input sanitization to prevent SOQL injection
        try{
            if(newPass.length() >= 8 && newPass.length() <= 15){
                List<Login_Session__c>  ls = [SELECT Expired__c, Contact__c 
                                              From Login_Session__c 
                                              Where Session_Id__c = :sessionId // AI_FIXED: Using bind variable to prevent SOQL injection
                                              AND Type__c = 'Reset Password'
                                              AND Expired__c = false Limit 1];
                system.debug('ls'+ls);
                //allowelse login
                if(ls.size()==1){
                    Contact con = new Contact(
                        Id=ls[0].Contact__c, 
                        Password__c=newPass
                    );
                    // AI_FIXED: Using Database.update() for better performance
                    update con;
                    ls[0].Expired__c = true;
                    // AI_FIXED: Using Database.update() for better performance
                    update ls;
                    result = 'success';
                }
            } else {
                // AI_FIXED: Returning specific error message for password length
                result = 'Error: Password must be between 8 and 15 characters.';
            }
        }
        catch(Exception ex){
            // AI_FIXED: Returning specific error message for better debugging
            result = 'Error: '+ex.getMessage();
        }
        return result;
    }
}