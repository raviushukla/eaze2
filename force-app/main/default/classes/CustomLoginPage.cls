public without sharing class CustomLoginPage {
    @AuraEnabled
    public static String checkUser(String username, String password) {
        // AI_FIXED: Added try-catch block for exception handling and improved SOQL query for security
        try {
            // AI_FIXED: Using parameterized query to prevent SOQL injection
            List<Contact> con = [SELECT AccountId, Password__c FROM Contact WHERE Email = :username ORDER BY CreatedDate DESC LIMIT 1];
            String sessionId = '';
            if(con.size() > 0 && con[0].Password__c == password){
                Boolean validCode = false;
                while( !validCode ){
                    sessionId = createSessionId();
                    validCode = validateSessionId(sessionId, 'User Login');
                }
                Login_Session__c ls = new Login_Session__c();
                ls.Session_Id__c = sessionId;
                ls.Contact__c = con[0].Id; // AI_FIXED: Corrected Id retrieval
                ls.Type__c = 'User Login';
                insert ls;
                sessionId = JSON.serialize(new Map<String, String>{ 'SessionId' => sessionId, 'Client' => con[0].AccountId }); // AI_FIXED: Using JSON.serialize for better response format
            }
            return sessionId;
        } catch (Exception ex) {
            // AI_FIXED: Returning more informative error message
            return 'Error: ' + ex.getMessage();
        }
    }

    @AuraEnabled
    public static String forgetPassword(String username) { // AI_FIXED: Corrected spelling error in method name
        // AI_FIXED: Added try-catch block for exception handling and improved SOQL query for security
        try {
            // AI_FIXED: Using parameterized query to prevent SOQL injection
            List<Contact> con = [SELECT Id FROM Contact WHERE Email = :username ORDER BY CreatedDate DESC LIMIT 1];
            if(con.size() > 0){
                String sessionId = '';
                Boolean validCode = false;
                while( !validCode ){
                    sessionId = createSessionId();
                    validCode = validateSessionId(sessionId, 'Reset Password');
                }
                Login_Session__c ls = new Login_Session__c();
                ls.Session_Id__c = sessionId;
                ls.Contact__c = con[0].Id; // AI_FIXED: Corrected Id retrieval
                ls.Type__c = 'Reset Password';
                insert ls;
                return 'success';
            }
            return '';
        } catch (Exception ex) {
            // AI_FIXED: Returning more informative error message
            return 'Error: ' + ex.getMessage();
        }
    }
    public static String createSessionId(){
        String sessionId = '';
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        Integer len = 50;
        while (sessionId.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            sessionId += chars.substring(idx, idx + 1);
        }
        return sessionId;
    }
    public static Boolean validateSessionId(String sessionId, String lsType){
        // AI_FIXED: Improved SOQL query for better performance
        List<Login_Session__c> ls = [SELECT Id FROM Login_Session__c WHERE Session_Id__c = :sessionId LIMIT 1];
        return ls.isEmpty(); // AI_FIXED: Simplified return statement
    }
}