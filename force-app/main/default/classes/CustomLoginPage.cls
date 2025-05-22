public without sharing class CustomLoginPage {
    @AuraEnabled
    public static String checkUser(String username, String password) {
        List<Contact> con = [Select AccountId, Password__c From Contact Where Email =: username Order By CreatedDate DESC Limit 1];
        String sessionId = '';
        if(con.size()>0 && con[0].Password__c == password){
            Boolean validCode = false;
            while( !validCode ){
                sessionId = createSessionId();
                validCode = validateSessionId(sessionId, 'User Login');
            }
            Login_Session__c ls = new Login_Session__c();
            ls.Session_Id__c = sessionId;
            ls.Contact__c =con[0].id;
            ls.Type__c = 'User Login';
            try{
                insert ls;
            }
            catch(Exception ex){
                return 'Error : '+ex.getMessage();
            }
            sessionId = '{"SessionId":"'+sessionId+'","Client":"'+con[0].AccountId+'"}';
        }
        return sessionId;      
    }
    
    @AuraEnabled
    public static String forgetPassowrd(String username) {
        List<Contact> con = [Select Email From Contact Where Email =: username Order By CreatedDate DESC Limit 1];
        if(con.size()>0){
            String sessionId = '';
            Boolean validCode = false;
            while( !validCode ){
                sessionId = createSessionId();
                validCode = validateSessionId(sessionId, 'Reset Password');
            }
            Login_Session__c ls = new Login_Session__c();
            ls.Session_Id__c = sessionId;
            ls.Contact__c =con[0].id;
            ls.Type__c = 'Reset Password';
            insert ls;
            
            return 'success';
        }
        return '';
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
        List<Login_Session__c> ls = [Select Id From Login_Session__c Where Session_Id__c =: sessionId Limit 1];
        if(ls.size()>0)
            isValid = false;
        return isValid;
    }
}