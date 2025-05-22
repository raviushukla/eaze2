public class CheckInvoiceStatusController {
    
    public Boolean IsPaid{get;set;}
    public String leadEmail{get;set;}
    
    public CheckInvoiceStatusController(){
        
        IsPaid = false;
        String leadEmail = ApexPages.currentPage().getParameters().get('email');
        List<Lead> fetchLead = [Select Id,Email,Status from Lead where Email =: leadEmail and IsConverted =: False ];
        if( fetchLead.size() > 0 ){
            if( fetchLead[0].Status == 'Setup Fee Paid To EAZE' ){
                IsPaid = true; 
            }else{
                leadEmail = fetchLead[0].Email;
            }
        }
    }
    
    public PageReference redirect(){
        if( IsPaid == false ){
            String urlStr = Label.Funding_Payment_URL;
            leadEmail = ApexPages.currentPage().getParameters().get('email');
            PageReference pageRef = new PageReference(urlStr+'?email='+leadEmail);
            return pageRef;
        }else{
            return null;
        }
    }
}