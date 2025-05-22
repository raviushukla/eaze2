public without sharing class ClientLogo {
    public String logo {set;get;}
    public String accountName{set;get;}
    public ClientLogo(){
        String docId = '';
        List<Document> doc = [SELECT Id FROM Document WHERE DeveloperName =: Label.Default_Client_Logo Limit 1];
        if(doc.size()>0)
            docId = doc[0].Id;
        //logo = '/servlet/servlet.FileDownload?file='+docId;
        String clientCode = apexpages.currentpage().getparameters().get('cl');
        if(clientCode != null){
            List<Account> acc = [Select Id,Name, (Select Name From Attachments Order By CreatedDate DESC) From Account Where Client_Code__c =: clientCode Order By CreatedDate DESC Limit 1];
            system.debug('acc : '+acc);
            if(acc.size()>0 && acc[0].Attachments.size() > 0){
                accountName = acc[0].Name;
                for(Attachment att: acc[0].Attachments){
                    String fileName = att.Name.toLowerCase();
                    if(fileName.contains('client logo') || fileName.contains('clientlogo') ){ 
                        logo = '/servlet/servlet.FileDownload?file='+att.Id;
                        system.debug('Logo : '+ logo);
                        break;
                    }
                }
            }
        }
    }
}