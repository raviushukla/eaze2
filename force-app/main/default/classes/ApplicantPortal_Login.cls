public without sharing class ApplicantPortal_Login {
	@AuraEnabled
    public static String checkUser(String username, String password) {
        List<Lead> leadList = [Select  CAN_Password__c, CAN_Username__c From Lead Where CAN_Username__c =: username Order By CreatedDate DESC Limit 1];
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
                return 'Error : '+ex.getMessage();
            }
            sessionId = '{"SessionId":"'+sessionId+'","userName":"'+username+'"}';
        }
        return sessionId;      
    }
    
    @AuraEnabled
    public static String forgetPassowrd(String username) {
        List<Lead> leadList = [Select CAN_Username__c,Email From Lead Where CAN_Username__c =: username Order By CreatedDate DESC Limit 1];
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