public without sharing class ClientLogo {
    public String logo {get;set;} // AI_FIXED: Changed to get;set; for better encapsulation
    public String accountName {get;set;} // AI_FIXED: Changed to get;set; for better encapsulation

    public ClientLogo(String clientCode){ // AI_FIXED: Added constructor to receive clientCode as parameter. Removed unnecessary variable initialization.
        try{
            if(clientCode != null){
                // AI_FIXED: Using bind variables to prevent SOQL injection
                List<Account> acc = [Select Id,Name, (Select Name, Id From Attachments Order By CreatedDate DESC) From Account Where Client_Code__c =: clientCode Order By CreatedDate DESC Limit 1];
                if(acc.size()>0 && acc[0].Attachments.size() > 0){
                    accountName = acc[0].Name;
                    for(Attachment att: acc[0].Attachments){
                        String fileName = att.Name.toLowerCase();
                        if(fileName.contains('client logo') || fileName.contains('clientlogo') ){ 
                            logo = '/servlet/servlet.FileDownload?file='+att.Id; // AI_FIXED: Kept original URL approach, but consider using ContentVersion for better performance and security.
                            break;
                        }
                    }
                }
            }
        } catch (Exception e){
            // AI_FIXED: Added exception handling to gracefully handle errors.  Log the error for debugging purposes.
            System.debug('Error retrieving client logo: ' + e.getMessage());
        }
    }
}