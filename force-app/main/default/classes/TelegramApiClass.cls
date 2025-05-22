public class TelegramApiClass {
    public static void deleteMessage(String chatId, String messageId){
        String accessToken = System.label.TelegramBotAccessToken;
        
        Map<String, String> requestHeaders = new Map<String, String>();
        HttpResponse res = new HttpResponse();
        
        // AI_FIXED: Using StringBuilder for better performance and avoiding potential issues with large chatIds and messageIds
        StringBuilder requestEndpointBuilder = new StringBuilder('https://api.telegram.org/bot');
        requestEndpointBuilder.append(accessToken);
        requestEndpointBuilder.append('/deleteMessage?chat_id=');
        requestEndpointBuilder.append(String.escapeSingleQuotes(chatId)); // AI_FIXED: Escaping single quotes to prevent SOQL injection
        requestEndpointBuilder.append('&message_id=');
        requestEndpointBuilder.append(String.escapeSingleQuotes(messageId)); // AI_FIXED: Escaping single quotes to prevent SOQL injection
        String requestEndpoint = requestEndpointBuilder.toString();

        try {
            if(test.isRunningTest()){
                res.setStatusCode(200);
                String body = '{"ok": true,"result": true}'; // AI_FIXED: Changed string to String for consistency
                res.setBody(body);
            }
            else{
                res = RESTCalloutHelper.makeCallout('POST', '', requestEndpoint, requestHeaders);
                System.debug(res.getBody());
                // AI_FIXED: Added error handling for callout exceptions
                if (res.getStatusCode() != 200) {
                    throw new Exception('Telegram API callout failed with status code: ' + res.getStatusCode() + ' and body: ' + res.getBody());
                }
            }
        } catch (Exception e) {
            // AI_FIXED: Added exception handling to log errors
            System.debug('Error deleting Telegram message: ' + e.getMessage());
            // AI_FIXED: Consider adding more robust error handling, such as logging to a custom object or sending an email alert.
        }
    }
}