public without sharing class AutoSendAgreement_AdobeSign {

    @InvocableMethod(label='Auto Send BSA from Account' description='This automatically sends Agreements based on template')
    public static list<RequestResult> createEnrolments( list<RequestParam> requestList ){
        list<RequestResult> rrList = new list<RequestResult>();
        for( RequestParam rp : requestList  ){
            String agreementId = 'Test';
            if( Userinfo.getName().equalsIgnoreCase('David Sneddon') && !Test.isRunningTest() ){
                autoSendLocal(rp.templateId,rp.masterRecordId);
            }else{
            	autoSendFuture(rp.templateId,rp.masterRecordId);
            }
            RequestResult rr = new RequestResult();
            rr.agreementId = agreementId;
            rrList.add(rr);
        }
        return rrList;
    }
    
    public class RequestParam{
        
        @InvocableVariable
        public String templateId;        
        
        @InvocableVariable
        public String masterRecordId;
    }
    
    public class RequestResult{
        @InvocableVariable
        public String agreementId;
    }
    
    
    public static void autoSendLocal( String tId, String mId){
        if( !Test.isRunningTest() ){
            echosign_dev1.AgreementTemplateService.load(tId,mId);
        }
    }
    
    @future(callout=true)
    public static void autoSendFuture( String tId, String mId){
        String tokenAndUrl = getAccesstoken();
        String access_token = tokenAndUrl.split('<>')[0];
        String url = tokenAndUrl.split('<>')[1];
        String requestMethod = 'POST';
        String requestBody = '{}';
        String requestEndpoint = url+'/services/apexrest/WebServiceAutoSendToAdobe?tId='+tId+'&rId='+mId;
        map<String,String> requestHeaders = new map<String,String>();
        requestHeaders.put('Authorization','Bearer '+access_token );
        
        HTTPResponse res = RESTCalloutHelper.makeCallout(requestMethod, requestBody, requestEndpoint, requestHeaders );
        system.debug(res.getBody());
        
    }
    
    public static string getAccesstoken(){
        String access_token = '';
        String instance_url = '';
        /*Organization org = [SELECT Id, IsSandbox FROM Organization WHERE Id = :userinfo.getOrganizationId()];
        String endpoint = 'https://login.salesforce.com';
        if( org.IsSandbox ){
            endpoint = 'https://test.salesforce.com';
        }*/
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:SF_Internal/services/oauth2/token');
        req.setMethod('POST');
        Http http = new Http();
        String reqBody = 	'grant_type=password&'+
                            'client_id='+Label.SF_Internal_ConsumerKey+'&'+
                            'client_secret='+Label.SF_Internal_ConsumerSecret+'&'+
                            'username={!$Credential.UserName}&'+
                            'password={!$Credential.Password}';
        req.setBody(reqBody);
        HTTPResponse res = http.send(req);
        System.debug(res.getBody() );
        String resBody = res.getBody();
        if(res.getStatusCode() == 200 ){
            Map<String, Object> m1 = (Map<String, Object>)Json.deserializeUntyped(resBody);
            access_token = (String)m1.get('access_token');
            instance_url = (String)m1.get('instance_url');
        }
        return access_token+'<>'+instance_url;
    }
    
}