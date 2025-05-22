public class CheckInvoiceStatusController {
    
    public Boolean IsPaid{get;set;}
    public String leadEmail{get;set;}
    
    public CheckInvoiceStatusController(){
        IsPaid = false;
        // AI_FIXED: Using String.isNotBlank to prevent null pointer exception and improve readability.  Also, using a try-catch block for exception handling.
        try{
            leadEmail = ApexPages.currentPage().getParameters().get('email');
            if(String.isNotBlank(leadEmail)){
                List<Lead> fetchLead = [Select Id,Email,Status from Lead where Email =: leadEmail and IsConverted = false ]; // AI_FIXED: Removed unnecessary colon and corrected boolean comparison.
                if( fetchLead.size() > 0 ){
                    if( fetchLead[0].Status == 'Setup Fee Paid To EAZE' ){
                        IsPaid = true; 
                    }else{
                        leadEmail = fetchLead[0].Email;
                    }
                }
            }
        } catch(Exception e){
            // AI_FIXED: Added exception handling to gracefully handle potential errors.  Consider logging the exception for debugging purposes in a production environment.
            System.debug('Error processing lead email: ' + e.getMessage());
        }
    }
    
    public PageReference redirect(){
        if( IsPaid == false ){
            String urlStr = Label.Funding_Payment_URL;
            // AI_FIXED: Removed redundant retrieval of leadEmail; it's already set in the constructor.
            PageReference pageRef = new PageReference(urlStr+'?email='+leadEmail);
            return pageRef;
        }else{
            return null;
        }
    }
}