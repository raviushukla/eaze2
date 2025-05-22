public class RESTCalloutHelper {
    
    public static HttpResponse makeCallout(String requestMethod, String requestBody, String requestEndpoint, map<String,String> requestHeaders)
    {
		  
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod(requestMethod);
        request.setEndpoint(requestEndpoint);
        System.debug('requestBody   '+requestBody);
        if( String.isNotBlank( requestBody ) ){
            request.setBody(requestBody);
        }
        for( String q : requestHeaders.keySet() ){
            request.setHeader(q,requestHeaders.get(q) );
        }
        system.debug('request==='+request);
        HttpResponse response = new HttpResponse();// AI_FIXED: Initialized HttpResponse to avoid NullPointerException
        try{
            response = http.send(request); // AI_FIXED: Moved HttpResponse assignment inside try block for exception handling.
        } catch(System.CalloutException e) { // AI_FIXED: Added try-catch block to handle CalloutExceptions.
            System.debug('Callout Exception: ' + e.getMessage()); // AI_FIXED: Added logging for better debugging.
            // Handle the exception appropriately, e.g., throw a custom exception, return a default response, etc.
        } catch (Exception ex){ // AI_FIXED: Added generic exception handling.
            System.debug('Generic Exception: ' + ex.getMessage()); // AI_FIXED: Added logging for better debugging.
        }
        return response;
    }

}