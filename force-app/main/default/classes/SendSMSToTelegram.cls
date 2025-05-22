public class SendSMSToTelegram {
    @InvocableMethod(label='Send Message To Telegram' description='This class is used to send Message to Telegram')
    public static void fetchSMSRecord(List<Telegram_Message__c> lstTelegramMessage) {
        // AI_FIXED: Added null check and handling for empty list
        if (lstTelegramMessage == null || lstTelegramMessage.isEmpty()) {
            System.debug('lstTelegramMessage is null or empty');
            return;
        }
        System.debug('lstTelegramMessage----->>'+lstTelegramMessage);
        sendSMS(lstTelegramMessage[0].Chat_Id__c,lstTelegramMessage[0].Message__c, lstTelegramMessage[0].Id);
    }
    
    @future(callout=true)
    public static void sendSMS(String chatId,String smsBody, String teleMsgId) {
        String accessToken = System.label.TelegramBotAccessToken;
        
        Map<String, String> requestHeaders = new Map<String, String>();
        HttpResponse res = new HttpResponse();
        
        // AI_FIXED: Using JSON.serialize for better security and readability
        // AI_FIXED: Added try-catch block for exception handling
        try {
            String requestBody = JSON.serialize(new Map<String, String>{'chat_id' => chatId, 'text' => smsBody});
            String requestEndpoint = 'https://api.telegram.org/bot'+accessToken+'/sendMessage';
            requestHeaders.put('content-type', 'application/json');
            
            if(test.isRunningTest()){
                res.setStatusCode(200);
                string body = '{"ok":true,"result":{"message_id":163,"from":{"id":1242200707,"is_bot":true,"first_name":"G2","username":"WakencodeG2_bot"},"chat":{"id":-347512819,"title":"Telegram","type":"group","all_members_are_administrators":true},"date":1594056515,"text":"test"}}';
                res.setBody(body);
            }
            else{
                res = RESTCalloutHelper.makeCallout('POST', requestBody, requestEndpoint, requestHeaders);
                System.debug(res.getBody());
            }
            if(res.getStatusCode() == 200){
                Map<String, object> resMap = (Map<String, object>)JSON.deserializeUntyped(res.getBody());
                // AI_FIXED: Added null checks to prevent NullPointerException
                if(resMap.containsKey('result') && resMap.get('result') != null){
                    Map<String, object> result = (Map<String, object>)resMap.get('result');
                    if(result.containsKey('message_id') && result.get('message_id') != null){
                        Integer temp = (Integer)result.get('message_id');
                        String messageId = String.valueOf(temp);
                        // AI_FIXED: Using DML operation in try-catch block for better error handling
                        try{
                            update new Telegram_Message__c(Id=teleMsgId, Message_Id__c = messageId);
                        } catch(Exception e){
                            System.debug('Error updating Telegram_Message__c: ' + e.getMessage());
                        }
                    }
                }
            }
        } catch (Exception e) {
            System.debug('Error sending message to Telegram: ' + e.getMessage());
            // AI_FIXED: Added proper exception handling
        }
    }
}