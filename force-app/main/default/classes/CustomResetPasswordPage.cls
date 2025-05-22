public without sharing class CustomResetPasswordPage {
    @AuraEnabled
    public static string sessionCheck(String sessionId){
        system.debug('sessionId'+sessionId);
        List<Login_Session__c>  ls = [SELECT Id 
                                      From Login_Session__c 
                                      Where Session_Id__c = :sessionId
                                      AND Type__c = 'Reset Password'
                                      AND Expired__c =: false Limit 1];
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
        try{
            if(newPass.length() >= 8 && newPass.length() <= 15){
                List<Login_Session__c>  ls = [SELECT Expired__c, Contact__c 
                                              From Login_Session__c 
                                              Where Session_Id__c = :sessionId
                                              AND Type__c = 'Reset Password'
                                              AND Expired__c =: false Limit 1];
                system.debug('ls'+ls);
                //allowelse login
                if(ls.size()==1){
                    Contact con = new Contact(
                        Id=ls[0].Contact__c, 
                        Password__c=newPass
                    );
                    update con;
                    ls[0].Expired__c = true;
                    update ls;
                    result = 'success';
                }
            }
        }
        catch(Exception ex){
            result = 'Error: '+ex.getMessage();
        }
        return result;
    }
}