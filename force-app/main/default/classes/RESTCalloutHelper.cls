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
        HttpResponse response = http.send(request);
        return response;
    }

}