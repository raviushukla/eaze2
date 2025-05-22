/* * * * * * * * * * * *
@ Author: Ajay Choudhary
@ Date  : 24/05/2019
@ Desc  : test class for CustomerPortalPasswordController
 * * * * * * * * * * * */
@isTest
public class CustomerPortalPasswordControllerTest {

    static testMethod void testNewPassword(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Email = 'test@gmail.com';
        ld.Status = 'New Lead';
        ld.Username__c = 'test@gmail.com';
        insert ld;
        ApexPages.currentPage().getParameters().put('userId', ld.Email);
        CustomerPortalPasswordController controller = new CustomerPortalPasswordController();
        CustomerPortalPasswordController.savePassword('test@123', ld.Email, '');
    }
    
    static testMethod void testForgotPassword(){
        Lead ld = new Lead();
        ld.LastName = 'test';
        ld.Email = 'test@gmail.com';
        ld.Status = 'New Lead';
        ld.Username__c = 'test@gmail.com';
        insert ld;
        Login_Session__c rs = new Login_Session__c();
        rs.Code__c = 1548475;
        rs.Lead__c = ld.Id;
        rs.Session_Id__c = 'test';
        rs.ResetLink_Expiraton__c = System.now().addDays(1);
        rs.Used__c = false;
        insert rs;
        ApexPages.currentPage().getParameters().put('code', String.valueOf(rs.Code__c));
        CustomerPortalPasswordController controller = new CustomerPortalPasswordController();
        CustomerPortalPasswordController.sendResetLink(ld.Email, '/CustomerPortalResetPasswordPage');
        CustomerPortalPasswordController.savePassword('123456', '', String.valueOf(rs.Code__c));
        
    }
}