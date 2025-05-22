@isTest
public class CheckInvoiceStatusController_Test {
    
    public static testmethod void checkInvoice(){
        Test.startTest();
        
        Lead ld = New Lead();
        ld.LastName = 'test Lead';
        ld.Status = 'Setup Fee Paid To EAZE';
        ld.Company = 'test';
        ld.Email = 'test@gmail.com';
        insert ld;
        
        PageReference pageRef = Page.CheckInvoieStatus;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('email','test@gmail.com');  
        
        CheckInvoiceStatusController obj = New CheckInvoiceStatusController();
        obj.redirect();
        
        Test.stopTest();
        
    }
    
    public static testmethod void checkInvoice1(){
        Test.startTest();
        
        Lead ld = New Lead();
        ld.LastName = 'test Lead';
        ld.Status = 'New Lead';
        ld.Company = 'test';
        ld.Email = 'test@gmail.com123';
        insert ld;
        
        PageReference pageRef = Page.CheckInvoieStatus;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('email','test@gmail.com');  
        
        CheckInvoiceStatusController obj = New CheckInvoiceStatusController();
        obj.redirect();
        
        Test.stopTest();
        
    }
}