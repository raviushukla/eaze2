public class TelegramApiClass {
    public static void deleteMessage(String chatId, String messageId){
        String accessToken = System.label.TelegramBotAccessToken;
        
        Map<String, String> requestHeaders = new Map<String, String>();
        HttpResponse res = new HttpResponse();
        
        String requestEndpoint = 'https://api.telegram.org/bot'+accessToken+'/deleteMessage?chat_id='+chatId+'&message_id='+messageId;
        
        if(test.isRunningTest()){
            res.setStatusCode(200);
            string body = '{"ok": true,"result": true}';
            res.setBody(body);
        }
        else{
            res = RESTCalloutHelper.makeCallout('POST', '', requestEndpoint, requestHeaders);
            System.debug(res.getBody());
        }
    }
}