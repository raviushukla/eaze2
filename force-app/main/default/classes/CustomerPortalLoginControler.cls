/* * * * * * * * * * * *
@ Author: Ajay Choudhary
@ Date  : 14/05/2019
@ Desc  : Controller class for CustomerPortalLogin vf page
 * * * * * * * * * * * */
public without sharing class CustomerPortalLoginControler {
    
    public  String loginUserId{get;set;}
    public  String loginPassword{get;set;}
    public  String sessionId{get;set;}
    public String loginReturnVlue {get;set;}
    
    public CustomerPortalLoginControler(){
    }
    
    
    public void validateLogin(){
        System.debug('loginUserId is '+loginUserId);
        // AI_FIXED: Added try-catch block for SOQL query and handled potential exceptions.  Improved error handling.
        try{
            List<Lead> lds = [SELECT Id, Name, Username__c, Password__c FROM Lead WHERE Username__c =:loginUserId AND IsConverted = false];
            system.debug('lds--'+lds.size()+'  '+lds);
            if(lds.size() == 0){
                loginReturnVlue = 'NoUser';
            }
            else{
                if(String.isBlank(lds[0].Password__c)) {
                    loginReturnVlue = 'NoPassword';
                }
                else if(!loginPassword.equals(lds[0].Password__c)){
                    loginReturnVlue = 'WrongPassword';
                }
                else if(loginPassword.equals(lds[0].Password__c)) {
                    loginReturnVlue = 'verified';
                }
            }
        } catch(Exception e){
            loginReturnVlue = 'Exception';
            System.debug('Exception during SOQL query: ' + e.getMessage()); // AI_FIXED: More informative debug message.
        }

        if(loginReturnVlue == 'verified'){
            Login_Session__c sc = new Login_Session__c();
            sc.Lead__c = lds[0].Id;
            sc.Session_Id__c = sessionId = generateRandomString(100);
            sc.Expiry_Time__c = System.now().addHours(12);
            // AI_FIXED: Added try-catch block for DML operation and handled potential exceptions. Improved error handling.
            try{
                insert sc;
            }
            catch(Exception e){
                System.debug('exception on inserting of session setting' +e);
                loginReturnVlue = 'Exception'; // AI_FIXED: Set loginReturnVlue to 'Exception' on DML error.
            }
        }
        // AI_FIXED: Added try-catch block for cookie setting and handled potential exceptions. Improved error handling.
        try{
            Cookie ck = new Cookie('siteSessionId',sessionId,null,43200,true);
            ApexPages.currentPage().setCookies(new Cookie[]{ck});
        }
        catch(Exception e){
            System.debug('exception on cookie' +e);
            loginReturnVlue = 'Exception'; // AI_FIXED: Set loginReturnVlue to 'Exception' on cookie error.
        }
    }
    
    
    public static String generateRandomString(Integer length){
        String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randomString = '';
        while(randomString.length() < length) {
            Integer idx = Math.mod(Math.abs(crypto.getRandomInteger()), chars.length());
            randomString += chars.substring(idx, idx+1);
        }
        return randomString;
    }
}