public without sharing class TrainingDocument {
    @AuraEnabled
    public static Network networkInfo(){
        Id networkId = Network.getNetworkId(); // AI_FIXED: Assigned Network.getNetworkId() to a variable for better readability and efficiency.
        if (networkId != null) {
            return [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :networkId];
        }
        return null;
    }
    @AuraEnabled
    public static List<Training_Document_Mapping__mdt> fetchMappingValues(){ // AI_FIXED: Changed return type to List<Training_Document_Mapping__mdt> for better type safety and to handle multiple records.
        return [Select DeveloperName, MasterLabel, Tag_Name__c, Tag_Value__c From Training_Document_Mapping__mdt];
    }
    @AuraEnabled
    public static Contact fetchAgentInfo(String rcdId){ // AI_FIXED: Changed return type to Contact for better type safety.
        try{
            Contact con = [Select Name, Email, Phone, AccountId, Account.Name, Account.Primary_Contact_Email__c, Account.Application_Link_New__c,
					   Account.Company_Script_Link__c,Account.Replay_Financing_Training_Link__c,
                       Agent_Application_Link_For_Prospects__c, Account.Team_Tracking_Link__c, Account.Telegram_Link__c,
                       Training_Main_Document_Id__c, Training_Attorney_Document_Id__c, Send_Training_Document__c
                       From Contact 
                       Where AccountId != null
                       AND Account.DSAD_Account__c = true
                       AND ID =: rcdId]; // AI_FIXED: Added try-catch block for exception handling.
            return con;
        } catch(Exception e){
            System.debug('Error fetching agent info: ' + e.getMessage()); // AI_FIXED: Added error logging.
            return null;
        }
    }
    @AuraEnabled
    public static String fetchMasterTemplate(String docType){
        String parentId = '';
        String masterDocName = '';
        docType = docType.capitalize();
        try{
            List<Training_Document__c> tdList = [Select Id From Training_Document__c Where Type__c =: docType Limit 1];
            if(tdList.size()>0){
                parentId = tdList[0].Id;
            }
            else{
                return null;
            }
            Application_Data__mdt appData;
            if(docType == 'Main'){ // AI_FIXED: Changed to 'Main' for case-insensitive comparison.
                appData = [Select value__c From Application_Data__mdt Where DeveloperName = 'TrainingDocumentMainDocName' Limit 1]; // AI_FIXED: Assigned query result to a variable for better readability.
            }
            else{
                appData = [Select value__c From Application_Data__mdt Where DeveloperName = 'TrainingDocumentAttorneyDocName' Limit 1]; // AI_FIXED: Assigned query result to a variable for better readability.
            }
            if(appData != null){ // AI_FIXED: Added null check for appData.
                masterDocName = appData.value__c;
            } else {
                return null; // AI_FIXED: Return null if appData is null.
            }
            List<ContentDocumentLink> cdl = [Select ContentDocumentId From ContentDocumentLink where LinkedEntityId =: parentId AND ContentDocument.Title LIKE : '%' + masterDocName + '%' Order By ContentDocument.CreatedDate DESC Limit 1]; // AI_FIXED: Added wildcard '%' to LIKE operator for partial matches.
            if(cdl.size()>0){
                ContentVersion doc = [SELECT VersionData FROM ContentVersion WHERE ContentDocumentId =: cdl[0].ContentDocumentId AND IsLatest = true];
                return EncodingUtil.base64Encode(doc.VersionData);
            }
            return null;
        } catch(Exception e){
            System.debug('Error fetching master template: ' + e.getMessage()); // AI_FIXED: Added error logging.
            return null;
        }
    }
    @AuraEnabled
    public static String fetchToken(){
        String accessToken = 'error';
        String username = '';
        String password = '';
        String organizationId = '';
        String requestEndpoint = '';
        try{
            Map<String, String> settings = new Map<String, String>(); // AI_FIXED: Use a map to store settings for better efficiency.
            for(Application_Data__mdt stt: [Select DeveloperName, value__c From Application_Data__mdt Where DeveloperName LIKE 'TrainingDocument%']){ // AI_FIXED: Optimized query by selecting only necessary fields.
                settings.put(stt.DeveloperName, stt.value__c);
            }
            requestEndpoint = settings.get('TrainingDocumentEndPoint');
            organizationId = settings.get('TrainingDocumentOrgId');
            username = settings.get('TrainingDocumentUserName');
            password = settings.get('TrainingDocumentPassword');
            // AI_FIXED: Removed redundant code for building the request body.  Using a more efficient method.
            String requestBody = buildSoapRequestBody(username, password, organizationId);
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
                response.setBody(TEST_RESPONSE_BODY); // AI_FIXED: Use a constant for the test response body.
            }
            else{
                response = http.send(request);
                system.debug('response : '+response.getBody());
                if (response.getStatusCode() == 200) {
                    accessToken = extractAccessToken(response.getBody()); // AI_FIXED: Extract the access token using a helper method.
                }
            }
        } catch (Exception e) {
            System.debug('Error fetching token: ' + e.getMessage()); // AI_FIXED: Added error logging.
            return 'error';
        }
        system.debug('accessToken : '+accessToken);
        return accessToken;
    }

    // AI_FIXED: Helper method to build the SOAP request body.
    private String buildSoapRequestBody(String username, String password, String organizationId) {
        return String.format(
            '<?xml version="1.0" encoding="UTF-8"?>' +
            '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="urn:partner.soap.sforce.com">' +
            '<SOAP-ENV:Header>' +
            '<ns1:LoginScopeHeader>' +
            '<ns1:organizationId>{0}</ns1:organizationId>' +
            '</ns1:LoginScopeHeader>' +
            '</SOAP-ENV:Header>' +
            '<SOAP-ENV:Body>' +
            '<ns1:login>' +
            '<ns1:username>{1}</ns1:username>' +
            '<ns1:password>{2}</ns1:password>' +
            '</ns1:login>' +
            '</SOAP-ENV:Body>' +
            '</SOAP-ENV:Envelope>',
            organizationId, username, password
        );
    }

    // AI_FIXED: Helper method to extract the access token from the response body.
    private String extractAccessToken(String responseBody) {
        // AI_FIXED: Use a more robust method for parsing XML response.  Consider using a dedicated XML parser library for production code.
        // This simplified example assumes a specific XML structure.  Adapt as needed for your actual response.
        String accessToken = 'error';
        try {
            XmlStreamReader reader = XmlStreamReader.create(responseBody);
            while (reader.hasNext()) {
                if (reader.getEventType() == XmlStreamReader.START_ELEMENT && reader.getLocalName() == 'sessionId') {
                    reader.next(); // Move to the text content
                    accessToken = reader.getText();
                    break;
                }
                reader.next();
            }
            reader.close();
        } catch (Exception e) {
            System.debug('Error parsing XML response: ' + e.getMessage());
        }
        return accessToken;
    }

    // AI_FIXED: Constant for test response body.
    private static final String TEST_RESPONSE_BODY = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="urn:partner.soap.sforce.com" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><loginResponse><result><metadataServerUrl>https://sbs--wncdev.my.salesforce.com/services/Soap/m/48.0/00Dn0000000EGdO</metadataServerUrl><passwordExpired>false</passwordExpired><sandbox>true</sandbox><serverUrl>https://sbs--wncdev.my.salesforce.com/services/Soap/u/48.0/00Dn0000000EGdO</serverUrl><sessionId>00Dn0000000EGdO!AQMAQEVCG2XFUUSuy4bFKq2yaXQGiaaBZzNGeUex2qTgvmwrISGG.mr1wKM4qIhTruD3lCr4M9xYGTDEFpaW8fJ2eDVmm5f0</sessionId><userId>005n0000003XjYqAAK</userId><userInfo><accessibilityMode>false</accessibilityMode><chatterExternal>false</chatterExternal><currencySymbol>$</currencySymbol><orgAttachmentFileSizeLimit>5242880</orgAttachmentFileSizeLimit><orgDefaultCurrencyIsoCode>USD</orgDefaultCurrencyIsoCode><orgDefaultCurrencyLocale>en_US</orgDefaultCurrencyLocale><orgDisallowHtmlAttachments>false</orgDisallowHtmlAttachments><orgHasPersonAccounts>true</orgHasPersonAccounts><organizationId>00Dn0000000EGdOEAW</organizationId><organizationMultiCurrency>false</organizationMultiCurrency><organizationName>SBSFinancing</organizationName><profileId>00en0000000M674AAC</profileId><roleIdxsi:nil="true"/><sessionSecondsValid>7200</sessionSecondsValid><userDefaultCurrencyIsoCodexsi:nil="true"/><userEmail>jitendra@wakencode.com</userEmail><userFullName>MyTestCon</userFullName><userId>005n0000003XjYqAAK</userId><userLanguage>en_US</userLanguage><userLocale>en_US</userLocale><userName>jitendra_trainingdocument@wakencode.com.sbsfin</userName><userTimeZone>America/Los_Angeles</userTimeZone><userType>CspLitePortal</userType><userUiSkin>Theme3</userUiSkin></userInfo></result></loginResponse></soapenv:Body></soapenv:Envelope>';
}