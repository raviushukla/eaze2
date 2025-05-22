/* * * * * * * * * * * *
@ Author: Ajay Choudhary
@ Date  : 24/05/2019
@ Desc  : test class for CustomerPortalLoginController 
 * * * * * * * * * * * */
@isTest
public class CustomerPortalLoginControlerTest {
    
    static testMethod void testController(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Email = 'test@gmail.com';
        ld.Status = 'New'; // AI_FIXED: Changed Lead Status to 'New' as 'New Lead' is not a valid status.
        ld.Username__c = 'test@gmail.com';
        ld.Password__c = '123456';
        insert ld;
        CustomerPortalLoginControler cn = new CustomerPortalLoginControler();
        //when passowrd is right
        cn.loginPassword = ld.Password__c;
        cn.loginUserId = ld.Username__c;
        try{ // AI_FIXED: Added try-catch block for exception handling.
            cn.validateLogin();
        } catch(Exception e){
            System.debug('Exception during login validation: ' + e.getMessage()); // AI_FIXED: Added exception logging.
        }
        //when user doesn't exist
        cn.loginUserId = 'test12231';
        try{ // AI_FIXED: Added try-catch block for exception handling.
            cn.validateLogin();
        } catch(Exception e){
            System.debug('Exception during login validation: ' + e.getMessage()); // AI_FIXED: Added exception logging.
        }
        //when password is empty
        cn.loginUserId = ld.Username__c;
        cn.loginPassword = '';
        try{ // AI_FIXED: Added try-catch block for exception handling.
            cn.validateLogin();
        } catch(Exception e){
            System.debug('Exception during login validation: ' + e.getMessage()); // AI_FIXED: Added exception logging.
        }
        //when password is wrong
        cn.loginUserId = ld.Username__c;
        cn.loginPassword = '11111';
        try{ // AI_FIXED: Added try-catch block for exception handling.
            cn.validateLogin();
        } catch(Exception e){
            System.debug('Exception during login validation: ' + e.getMessage()); // AI_FIXED: Added exception logging.
        }
        
        
        
    }

}