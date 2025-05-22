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
        List<Lead> lds = [SELECT Id, Name, Username__c, Password__c FROM Lead  WHERE Username__c =:loginUserId and isconverted = false];
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
        if(loginReturnVlue == 'verified'){
            Login_Session__c sc = new Login_Session__c();
            sc.Lead__c = lds[0].Id;
            sc.Session_Id__c = sessionId = generateRandomString(100);
            sc.Expiry_Time__c = System.now().addHours(12);
            try{
                insert sc;
            }
            catch(Exception e){
                System.debug('exception on inserting of session setting' +e);
            }
        }
        Cookie ck = new Cookie('siteSessionId',sessionId,null,43200,true);
        try{
            ApexPages.currentPage().setCookies(new Cookie[]{ck});
        }
        catch(Exception e){
            System.debug('exception on cookie' +e);
            loginReturnVlue = 'Exception';
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