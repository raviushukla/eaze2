/* * * * * * * * * * * *
@ Author: Ajay Choudhary
@ Date  : 13/05/2019
@ Desc  : Controller class for CustomerPortalForgotPasswod and CustomerPortalResetPassword vf page
 * * * * * * * * * * * */
public without sharing  class CustomerPortalPasswordController {
    public String userId{get; set;}
    public Boolean isNewPassword{get; set;}
    public String heading {get; set;}
    public Boolean isLinkExpired {get;set;}
    public Boolean isValid {get;set;}
    public String code {get;set;}
    public CustomerPortalPasswordController(){
        userId = ApexPages.currentPage().getParameters().get('userId');
        code = ApexPages.currentPage().getParameters().get('code');
        List<Login_Session__c> rps = new List<Login_Session__c>();
        List<Lead> ld = new List<Lead>();
        //if no parameter present in url 
        if(String.isBlank(code) && String.isBlank(userId)) {
            isValid = false;
        }
        //if code is present in url so it will be for forgot password 
        if(String.isNotBlank(code)){
            System.debug('code is' +code);
            rps = [SELECT Id, Code__c, Used__c, Lead__c, ResetLink_Expiraton__c FROM Login_Session__c WHERE Code__c =:Decimal.valueOf(code)];
        }
        
        if(rps != null && rps.size() > 0){
            isNewPassword = false;
            isValid = true;
            heading = 'Reset Password';
            System.debug('link time ' +rps[0].ResetLink_Expiraton__c);
            //check if reset passsword link has expired or not
            if(rps[0].ResetLink_Expiraton__c < System.now() || rps[0].Used__c == true) {
                System.debug('link time ' +rps[0].ResetLink_Expiraton__c);
                isLinkExpired = true;
            }
            else{
                isLinkExpired = false;
            }
        }
        
        
        if(String.isNotBlank(userId)) {
            ld = [SELECT Id, Username__c, Password__c, ResetLink_Expiraton__c FROM Lead WHERE Username__c =:userId];
            if(ld.size() > 0){
                if(String.isBlank(ld[0].Password__c)){
                    heading = 'New Password';
                    isNewPassword = true;
                    isValid = true;
                }
                else{
                    isValid = false;
                }
                
                System.debug('lead is '+ld);
                
            }
            else {
            }
        }
        
        
    }
    
    //function to save password either first time or another time
    @RemoteAction
    public static boolean savePassword(String password, String userIds, String resetCode){
        List<Login_Session__c> resetPasswordSettingList = new List<Login_Session__c> ();
        if(String.isNotBlank(resetCode)) {
            resetPasswordSettingList = [SELECT Id, Code__c, Used__c, Lead__c, ResetLink_Expiraton__c FROM Login_Session__c WHERE Code__c =:Decimal.valueOf(resetCode)];
            if(resetPasswordSettingList.size() > 0 ){
                resetPasswordSettingList[0].Used__c = true;
                update resetPasswordSettingList;
            }
        }
        Lead toUpdateLead = new Lead();
        //if perrson is setting password first time
        if(String.isNotBlank(userIds)){
            toUpdateLead = [SELECT Id, Username__c, Password__c FROM Lead WHERE Username__c =:userIds];
        }
        //if perrson is restting password
        else if(String.isNotBlank(resetCode)){
            toUpdateLead = new Lead(Id=resetPasswordSettingList[0].Lead__c);
        }
        toUpdateLead.Password__c = password;
        try{
            update toUpdateLead;
            return true;
        }
        catch(Exception e) {
            System.debug('Exception while updatng password is : '+e);
            return false;
        }
    }
    
    @RemoteAction
    public static String sendResetLink(String registeredEmail, String resetLink){
        String returnValue = '';
        List<Lead> toSendLead = [SELECT Id, Username__c, Email FROM Lead WHERE Email =:registeredEmail and isconverted = false];
        if(toSendLead.size() == 0){
            returnValue = 'NoUser';
        }
        else{
            Integer code = Math.round(Math.random()*1000000000);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(new List<String> {toSendLead[0].Email});
            String body = 'Hi, <br/>'+
                'You can reset your password by clicking here  <a href='+resetLink+code+'>Click Here</a>.<br/>'+
                'if above link does not work, please copy paste this link ' +resetLink+code+ ' in your browser<br/><br/>'+
                'This link is valid for one hour.<br/><br/>'+
                'Regards,<br/>'+
                'EAZE Consulting Team';
            email.setHtmlBody(body);
            Login_Session__c rp = new Login_Session__c();
            rp.Code__c = code;
            rp.Lead__c = toSendLead[0].Id;
            rp.Session_Id__c = 'reset password';
            rp.ResetLink_Expiraton__c = System.now().addHours(1);
            try{
                // update toSendLead;
                insert rp;
                Messaging.sendEmail(new List<Messaging.Email> {email});
                returnValue = 'Sent';
            }
            catch(Exception e) {
                System.debug('exception while sending emial: '+e);
                returnValue = 'Fail';
            }
            
        }
        return returnValue;
    }
}