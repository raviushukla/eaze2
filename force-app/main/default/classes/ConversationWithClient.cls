public class ConversationWithClient {
    
    // fetching client.
    @AuraEnabled
    public static List<clientWrapper> fetchClients(){ // AI_FIXED: Changed return type to List<clientWrapper> for clarity and consistency.
        
        Integer fromDate = Integer.valueOf(Label.From_Months);
        Date dt = Date.today().addMonths(-fromDate);
        
        List<clientWrapper> clientList = new List<clientWrapper>();
        
        List<Lead> clientsLd = [SELECT Name, Phone, MobilePhone, Mobile_Custom__c, Email FROM Lead WHERE IsConverted = false AND CreatedDate >=:dt ORDER by Latest_SMS_Timestamp__c DESC NULLS LAST];
        system.debug('clientsLd : '+clientsLd);
        if(clientsLd.size()>0){
            for(Lead cl: clientsLd){
                clientList.add(new clientWrapper(cl.Id, cl.Name, cl.Email, cl.Phone, cl.Mobile_Custom__c));
            }
        }
        return clientList;
    }
    
    // fetching records form twilio sms.
    @AuraEnabled
    public static List<Twilio_SMS__c> fetchConversation(String clientId){ // AI_FIXED: Changed return type to List<Twilio_SMS__c> for clarity and consistency.
        List<Twilio_SMS__c> convr = [SELECT SMS_Body__c, Type__c, Leads__c,
                                     CreatedDate, SMS_Recipient__c, SMS_Status__c
                                     FROM Twilio_SMS__c 
                                     WHERE Leads__c =: clientId // AI_FIXED: Removed unnecessary condition 'Leads__c != null' as it's redundant with the equality check.
                                     Order By CreatedDate ASC];
        return convr;
    }
    
    //  send message to client.
    @AuraEnabled
    public static String sendMessage(String clientId, String smsBody, String clientMobile){ // AI_FIXED: Changed return type to String for better error handling.
        Twilio_SMS__c msg = new Twilio_SMS__c(
            SMS_Body__c=smsBody,
            Leads__c=clientId,
            Type__c = 'Outgoing',
            SMS_Status__c = 'Sent',
            SMS_Recipient__c = clientMobile
            //Medium__c = 'Twilio'
        );
        try{
        	insert msg;
            system.debug('sms Id : '+msg.Id);
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for broader exception handling.
            return 'Error sending message: ' + ex.getMessage(); // AI_FIXED: Improved error message for better user feedback.
        }
    }
    
    // fetching unread messages
    @AuraEnabled
    public static List<Twilio_SMS__c> fetchNotification(){ // AI_FIXED: Changed return type to List<Twilio_SMS__c> for clarity and consistency.
        List<Twilio_SMS__c> convr = [SELECT SMS_Body__c, Leads__c,Leads__r.name,
                                     CreatedDate
                                     FROM Twilio_SMS__c 
                                     WHERE Leads__c != null 
                                     AND Type__c = 'Incoming' 
                                     AND Unseen__c = true
                                     Order By CreatedDate DESC];
        
        return convr;
    }
    
    // mark messages as read for selected client
    @AuraEnabled
    public static String markSMSasRead(List<String> twilioSmsIds){ // AI_FIXED: Changed return type to String for better error handling.
        try{
            system.debug('twilioSmsIds : '+twilioSmsIds);
            List<Twilio_SMS__c> twList = new List<Twilio_SMS__c>();
            for(String twId: twilioSmsIds){
                Twilio_SMS__c tw = new Twilio_SMS__c(Id = twId, Unseen__c = false); // AI_FIXED: Simplified code for better readability.
                twList.add(tw);
            }
            update twList;
            return 'success';
        }
        catch(Exception ex){ // AI_FIXED: Changed exception type to Exception for broader exception handling.
            return 'Error marking messages as read: ' + ex.getMessage(); // AI_FIXED: Improved error message for better user feedback.
        }
    }
    public class clientWrapper{
        @AuraEnabled
        public String clientId;
        @AuraEnabled
        public String clientName;
        @AuraEnabled
        public String clientEmail;
        @AuraEnabled
        public String clientPhone;
        @AuraEnabled
        public String clientMobile;
        
        public clientWrapper(String clientId, String clientName, String clientEmail, String clientPhone, String clientMobile){
            this.clientId = clientId;
            this.clientName = clientName;
            this.clientEmail = clientEmail;
            this.clientPhone = clientPhone;
            this.clientMobile = clientMobile;
        }
    }
}