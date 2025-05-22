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
        
        // AI_FIXED: Corrected typo in PageReference
        PageReference pageRef = Page.CheckInvoiceStatus; 
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
        
        // AI_FIXED: Corrected typo in PageReference
        PageReference pageRef = Page.CheckInvoiceStatus; // AI_FIXED: Corrected typo in PageReference
        Test.setCurrentPage(pageRef);
        // AI_FIXED: Using the email from the inserted Lead for consistency and better test coverage.
        ApexPages.currentPage().getParameters().put('email',ld.Email);  
        
        CheckInvoiceStatusController obj = New CheckInvoiceStatusController();
        obj.redirect();
        
        Test.stopTest();
        
    }
}