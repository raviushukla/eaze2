global class CreateDTCAEmailService implements Messaging.InboundEmailHandler {
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope envelop){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        String toAddress = email.toAddresses != null && email.toAddresses.size() > 0 ? email.toAddresses[0] : null; // AI_FIXED: Added null check for email.toAddresses
        String emailServiceName = null; // AI_FIXED: Initialized emailServiceName to null
        
        // AI_FIXED: Optimized email service name search using a single loop and containsIgnoreCase
        if (email.toAddresses != null) {
            for(String emailname : email.toAddresses){
                if(emailname.containsIgnoreCase('createdirecttocustomerapplication') || emailname.containsIgnoreCase('dtoc-emails')){
                    emailServiceName = emailname;
                    break; // AI_FIXED: Added break to exit loop after finding the service name
                }
            }
        }
        
        if(String.isBlank(emailServiceName) && email.ccAddresses != null){
            for(String ccemailName : email.ccAddresses){
                if(ccemailName.containsIgnoreCase('createdirecttocustomerapplication') || ccemailName.containsIgnoreCase('dtoc-emails')){ // AI_FIXED: Corrected variable name to ccemailName
                    emailServiceName = ccemailName;
                    break; // AI_FIXED: Added break to exit loop after finding the service name
                }
            }
        }

        Direct_To_Client_Application__c client = new Direct_To_Client_Application__c();
        String emailBody = email.plainTextBody != null ? email.plainTextBody : email.htmlBody;
        String subject = email.subject;
        String name;

        try{ // AI_FIXED: Added try-catch block for exception handling
            List<Direct_To_Client_Application__c> clientList = [SELECT Id, Name, Email__c FROM Direct_To_Client_Application__c WHERE Email__c = :toAddress ]; // AI_FIXED: Corrected SOQL query capitalization
            if(clientList.size() > 0){
                client.Id = clientList[0].Id;
                if( subject.containsIgnoreCase('Welcome to Eaze Consulting!') ){
                    client.Status__c = 'Approved';
                    update client; // AI_FIXED: Corrected Upsert to update
                }
                if(emailBody.containsIgnoreCase('Upon review of your application, we regret to inform you that we are unable to open an account for you at this time')){
                    client.Status__c = 'Declined';
                    update client; // AI_FIXED: Corrected Upsert to update
                }
            }else{
                List<Account> aL = [Select Id, Paid_For_FinFive__c from Account where Primary_Contact__r.Email = :toAddress LIMIT 1]; // AI_FIXED: No changes needed, but keeping for consistency
                if( aL.size() > 0 ){
                    client.Account__c = aL[0].Id; // AI_FIXED: Corrected variable name to aL
                }
                name = emailBody.substringBetween('Hello ',',');
                if( String.isNotBlank(name) && name.length() > 80 ){
                    name = name.abbreviate(80);
                }
                client.Name = name != null ? name : 'Name not found';
                client.Email__c = toAddress;   
                if(emailBody.containsIgnoreCase('Thank you for applying for a Eaze Consulting account. Please allow us 2-3 business days to review your application.')){
                    client.Status__c = 'New';
                    insert client; // AI_FIXED: Changed Upsert to insert since it's a new record
                }   
            }
        } catch(Exception e){
            // AI_FIXED: Added exception handling
            System.debug('Error processing email: ' + e.getMessage());
            result.setErrorStatus('Error', e.getMessage()); // AI_FIXED: Set error status in result
        }
        
        StringBuilder emailBodyBuilder = new StringBuilder(); // AI_FIXED: Using StringBuilder for better performance
        emailBodyBuilder.append('To: ').append(email.toAddresses != null ? email.toAddresses.toString() : 'N/A').append('\n'); // AI_FIXED: Added null check and N/A for null case
        emailBodyBuilder.append('Subject: ').append(email.subject).append('\n');
        emailBodyBuilder.append('Body: ').append(email.plainTextBody != null ? email.plainTextBody : email.htmlBody);
        emailBody = emailBodyBuilder.toString();

        createApiLogs(client.Id, emailBody, emailServiceName);
        return result;
    }
    
    public static void createApiLogs(String clientId, String emailbody, String emailName){
        API_Log__c apilog = new API_Log__c();
        apilog.Source_Destination__c = 'DTC - ' + (clientId != null ? clientId : 'N/A'); // AI_FIXED: Added null check for clientId
        apilog.Endpoint_URL__c = emailName != null ? emailName : 'N/A'; // AI_FIXED: Added null check for emailName
        apilog.Parent_Record__c = clientId;
        apilog.Request_Body__c = emailbody.abbreviate(32760);
        apilog.Request_Type__c = 'POST';
        apilog.Request_Status__c = 'Received';
        apilog.Type__c = 'Inbound';
        insert apilog;
    }
}