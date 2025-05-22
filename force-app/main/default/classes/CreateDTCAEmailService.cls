global class CreateDTCAEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,Messaging.InboundEnvelope envelop){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String toAddress = email.toAddresses[0];
        String emailServiceName;
        for(String emailname : email.toAddresses){
            if(emailname.contains('createdirecttocustomerapplication') || emailname.contains('dtoc-emails')){
                emailServiceName = emailname;
            }
        }
        if(String.isBlank(emailServiceName) && email.ccAddresses != null){
            for(String ccemailName : email.ccAddresses){
                if(ccemailname.contains('createdirecttocustomerapplication') || ccemailname.contains('dtoc-emails')){
                    emailServiceName = ccemailname;
                }
            }
        }
        List<Direct_To_Client_Application__c> clientList = [SELECT Id, Name, Email__c from Direct_To_Client_Application__c Where Email__c = :toAddress ];
        Direct_To_Client_Application__c client = new Direct_To_Client_Application__c();
        String emailBody = email.plainTextBody != null ? email.plainTextBody : email.htmlBody;
        String subject = email.subject;
        String name;
        if(clientList.size() > 0){
            client.Id = clientList[0].Id;
            if( subject.containsIgnoreCase('Welcome to Eaze Consulting!') ){
                client.Status__c = 'Approved';
                Upsert Client;
            }
            if(emailBody.containsIgnoreCase('Upon review of your application, we regret to inform you that we are unable to open an account for you at this time')){
                client.Status__c = 'Declined';
                Upsert Client;
            }
        }else{
            List<Account> aL = [Select Id, Paid_For_FinFive__c from Account where Primary_Contact__r.Email = :toAddress LIMIT 1];
            if( aL.size() > 0 ){
                Client.Account__c = al[0].Id;
            }
            name = emailBody.substringBetween('Hello ',',');
            if( String.isNotBlank(name) && name.length() > 80 ){
                name = name.abbreviate(80);
            }
            client.Name = name != null ? name : 'Name not found';
            
            client.Email__c = toAddress;   
            
            if(emailBody.containsIgnoreCase('Thank you for applying for a Eaze Consulting account. Please allow us 2-3 business days to review your application.')){
                client.Status__c = 'New';
                Upsert Client;
            }   
        }
        
        emailBody = 'To: '+email.toAddresses.toString() +'\n';
        emailBody += 'Subject: '+email.subject;
        emailBody += 'Body: '+email.plainTextBody != null ? email.plainTextBody : email.htmlBody;
        
        
        createApiLogs(client.Id, emailBody, emailServiceName);
        
        return result;
    }
    
    public static void createApiLogs(String clientId, String emailbody, String emailName){
        
        API_Log__c apilog = new API_Log__c();
            
        apilog.Source_Destination__c = 'DTC - '+clientId;
        apilog.Endpoint_URL__c = emailName;
        apilog.Parent_Record__c = clientId;
        apilog.Request_Body__c = emailbody.abbreviate(32760);
        apilog.Request_Type__c = 'POST';
        apilog.Request_Status__c = 'Received';
        apilog.Type__c = 'Inbound';
        
        insert apilog;
        
    }
}