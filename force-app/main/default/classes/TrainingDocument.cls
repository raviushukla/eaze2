public without sharing class TrainingDocument {
    @AuraEnabled
    public static Network networkInfo(){
        if (Network.getNetworkId() != null) {
            return [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
        }
        return null;
    }
    @AuraEnabled
    public static object fetchMappingValues(){
        return [Select DeveloperName, MasterLabel, Tag_Name__c, Tag_Value__c From Training_Document_Mapping__mdt];
    }
    @AuraEnabled
    public static object fetchAgentInfo(String rcdId){
        Contact con = [Select Name, Email, Phone, AccountId, Account.Name, Account.Primary_Contact_Email__c, Account.Application_Link_New__c,
					   Account.Company_Script_Link__c,Account.Replay_Financing_Training_Link__c,
                       Agent_Application_Link_For_Prospects__c, Account.Team_Tracking_Link__c, Account.Telegram_Link__c,
                       Training_Main_Document_Id__c, Training_Attorney_Document_Id__c, Send_Training_Document__c
                       From Contact 
                       Where AccountId != null
                       AND Account.DSAD_Account__c = true
                       AND ID =: rcdId];
        return con;
    }
    @AuraEnabled
    public static object fetchMasterTemplate(String docType){
        String parentId = '';
        String masterDocName = '';
        docType = docType.capitalize();
        List<Training_Document__c> tdList = [Select Id From Training_Document__c Where Type__c =: docType Limit 1];
        if(tdList.size()>0){
            parentId = tdList[0].Id;
        }
        else{
            return null;
        }
        if(docType == 'main'){
            //masterDocName = Label.Master_Training_Doc_Main;
            masterDocName = [Select value__c From Application_Data__mdt Where DeveloperName = 'TrainingDocumentMainDocName' Limit 1].value__c;
        }
        else{
            //masterDocName = Label.Master_Training_Doc_Attorneys;
            masterDocName = [Select value__c From Application_Data__mdt Where DeveloperName = 'TrainingDocumentAttorneyDocName' Limit 1].value__c;
        }
        List<ContentDocumentLink> cdl = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: parentId AND ContentDocument.Title LIKE : masterDocName Order By ContentDocument.CreatedDate DESC Limit 1];
        if(cdl.size()>0){
            ContentVersion doc = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: cdl[0].ContentDocumentId AND IsLatest = true];
            return EncodingUtil.base64Encode(doc.VersionData);
        }
        return null;
    }
    @AuraEnabled
    public static String fetchToken(){
        String accessToken = 'error';
        String username = '';
        String password = '';
        String organizationId = '';
        String requestEndpoint = '';
        List<Application_Data__mdt> setting = [Select DeveloperName, MasterLabel, value__c From Application_Data__mdt Where DeveloperName LIKE 'TrainingDocument%'];
        if(setting.size()>0){
            for(Application_Data__mdt stt: setting){
                if(stt.DeveloperName == 'TrainingDocumentEndPoint'){
                    requestEndpoint = stt.value__c;
                }
                else if(stt.DeveloperName == 'TrainingDocumentOrgId'){
                    organizationId = stt.value__c;
                }
                else if(stt.DeveloperName == 'TrainingDocumentUserName'){
                    username = stt.value__c;
                }
                else if(stt.DeveloperName == 'TrainingDocumentPassword'){
                    password = stt.value__c;
                }
            }
            String requestBody = '<?xml version=\"1.0" encoding="UTF-8"?>';
            requestBody += '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:partner.soap.sforce.com">';
            requestBody += '<SOAP-ENV:Header>';
            requestBody += '<ns1:LoginScopeHeader>';
            requestBody += '<ns1:organizationId>'+organizationId+'</ns1:organizationId>';
            requestBody += '</ns1:LoginScopeHeader>';
            requestBody += '</SOAP-ENV:Header>';
            requestBody += '<SOAP-ENV:Body>';
            requestBody += '<ns1:login>';
            requestBody += '<ns1:username>'+username+'</ns1:username>';
            requestBody += '<ns1:password>'+password+'</ns1:password>';
            requestBody += '</ns1:login>';
            requestBody += '</SOAP-ENV:Body>';
            requestBody += '</SOAP-ENV:Envelope>';
            
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setEndpoint(requestEndpoint);
            request.setMethod('POST');
            request.setHeader('SOAPAction', 'login');
            request.setHeader('content-type', 'text/xml');
            request.setBody(requestBody);
            request.setTimeout(120000);
            if(Test.isRunningTest()){
                response.setStatusCode(200);
                string body = '<?xmlversion="1.0"encoding="UTF-8"?><soapenv:Envelopexmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"xmlns="urn:partner.soap.sforce.com"xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>https://sbs--wncdev.my.salesforce.com/services/Soap/m/48.0/00Dn0000000EGdO</metadataServerUrl><passwordExpired>false</passwordExpired><sandbox>true</sandbox><serverUrl>https://sbs--wncdev.my.salesforce.com/services/Soap/u/48.0/00Dn0000000EGdO</serverUrl><sessionId>00Dn0000000EGdO!AQMAQEVCG2XFUUSuy4bFKq2yaXQGiaaBZzNGeUex2qTgvmwrISGG.mr1wKM4qIhTruD3lCr4M9xYGTDEFpaW8fJ2eDVmm5f0</sessionId><userId>005n0000003XjYqAAK</userId><userInfo><accessibilityMode>false</accessibilityMode><chatterExternal>false</chatterExternal><currencySymbol>$</currencySymbol><orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode><orgDefaultCurrencyLocale>en_US</orgDefaultCurrencyLocale><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>true</orgHasPersonAccounts><organizationId>00Dn0000000EGdOEAW</organizationId><organizationMultiCurrency>false</organizationMultiCurrency><organizationName>SBSFinancing</organizationName><profileId>00en0000000M674AAC</profileId><roleIdxsi:nil="true"/><sessionSecondsValid>7200</sessionSecondsValid><userDefaultCurrencyIsoCodexsi:nil="true"/><userEmail>jitendra@wakencode.com</userEmail><userFullName>MyTestCon</userFullName><userId>005n0000003XjYqAAK</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>jitendra_trainingdocument@wakencode.com.sbsfin</userName><userTimeZone>America/Los_Angeles</userTimeZone><userType>CspLitePortal</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></soapenv:Envelope>';
                response.setBody(body);
            }
            else{
                response = http.send(request);
                system.debug('response : '+response.getBody());
                
                if (response.getStatusCode() == 200) {
                    DOM.Document doc = response.getBodyDocument();
                    for(Dom.XmlNode fluxNode: doc.getRootElement().getChildElements()) {
                        for(Dom.XmlNode fluxChildNode: fluxNode.getChildElements()) {
                            for(Dom.XmlNode fluxChildOfChildNode: fluxChildNode.getChildElements()) {
                                if(fluxChildOfChildNode.getName() == 'result') {
                                    accessToken = fluxChildOfChildNode.getChildElement('sessionId','urn:partner.soap.sforce.com').getText();
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('accessToken : '+accessToken);
        return accessToken;
    }
}