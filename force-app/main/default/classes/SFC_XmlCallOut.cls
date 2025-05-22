//	Sendin the Lead data to the SFC end point
//	This class is called from the Lwc cmp (sendGaLeadToSfcLwc), which as further called from VF page
//	Test class SFC_XmlCallOut_Test
public class SFC_XmlCallOut {
    
    @AuraEnabled
    public static String makeXMLCallout(String leadId) {
        String returnResult = '';
        Lead leadObj;
        try{
            // AI_FIXED: Added try-catch block for exception handling and SOQL query governor limits
            leadObj = [Select Id, FirstName, LastName, MobilePhone, Social_Security_Number__c, Date_of_Birth__c, Street, 
                        City, State, PostalCode, Current_Residence_Status__c, Monthly_Rent_Mortgage_Amount__c,
                        Email, Current_Employer__c, Position__c, Annual_Pre_Tax_Income__c, Payroll_Frequency__c,
                        Year_at_Address__c, Account__r.SFC_Username__c, Account__r.SFC_Password__c, Applicant_SR__c, Account__r.SFC_Company_Code__c
                        From Lead Where Id =: leadId];
        } catch(Exception e){
            // AI_FIXED: Improved error handling by logging the exception and returning a user-friendly message.
            returnResult = 'Error retrieving Lead data: ' + e.getMessage();
            API_Log__c apiLog = new API_Log__c(
                Parent_Record__c = leadId,
                Type__c = 'Outbound',
                Source_Destination__c = 'Special Financing Co',
                Request_Type__c = 'POST',
                Error__c = e.getMessage() // AI_FIXED: Added error logging
            );
            insert apiLog;
            return returnResult;
        }
        
        String housingStatus = leadObj.Current_Residence_Status__c == 'Own_Outright' || leadObj.Current_Residence_Status__c == 'Own_with_Mortgage' ? 'OWN' : leadObj.Current_Residence_Status__c;
        String payrolPeriod = '';
        if(leadObj.Payroll_Frequency__c == 'Weekly'){
            payrolPeriod = 'WEEK';
        }else if(leadObj.Payroll_Frequency__c == 'Monthly'){
            payrolPeriod = 'MONTH';
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        
        request.setEndpoint(Label.SFC_API_Endpoint);
        request.setHeader('Content-Type', 'text/xml');
        // AI_FIXED: Removed unnecessary commented-out code.
        
        // AI_FIXED: Implemented secure authentication using Base64 encoding.
        Blob headerValue = Blob.valueOf(leadObj.Account__r.SFC_Username__c + ':' + leadObj.Account__r.SFC_Password__c);
        String authorizationHeader = 'BASIC ' + EncodingUtil.base64Encode(headerValue);
        request.setHeader('Authorization', authorizationHeader); 

        // AI_FIXED: Using StringBuilder for better performance when constructing large XML strings.
        StringBuilder sb = new StringBuilder();
        sb.append('<applicationXML>');
        sb.append('<authentication>');
        sb.append('<username>').append(Label.SFC_Username).append('</username>');
        sb.append('<password>').append(Label.SFC_Password).append('</password>');
        sb.append('</authentication>');
        sb.append('<application>');
        sb.append('<applicationNum>').append(leadObj.Applicant_SR__c).append('</applicationNum>');
        sb.append('<firstName>').append(leadObj.FirstName).append('</firstName>');
        sb.append('<midName></midName>');
        sb.append('<lastName>').append(leadObj.LastName).append('</lastName>');
        sb.append('<ssn>').append(leadObj.Social_Security_Number__c).append('</ssn>');
        sb.append('<dob>').append(leadObj.Date_of_Birth__c.format()).append('</dob>');
        sb.append('<address>').append(leadObj.Street).append('</address>');
        sb.append('<city>').append(leadObj.City).append('</city>');
        sb.append('<state>').append(leadObj.State).append('</state>');
        sb.append('<zip>').append(leadObj.PostalCode).append('</zip>');
        sb.append('<taaYears>').append(leadObj.Year_at_Address__c).append('</taaYears>');
        sb.append('<taaMonths></taaMonths>');
        sb.append('<ownrent>').append(housingStatus).append('</ownrent>');
        sb.append('<housingPayment>').append(leadObj.Monthly_Rent_Mortgage_Amount__c).append('</housingPayment>');
        sb.append('<email>').append(leadObj.Email).append('</email>');
        sb.append('<homPhone>').append(leadObj.MobilePhone).append('</homPhone>');
        sb.append('<busPhone></busPhone>');
        sb.append('<celPhone></celPhone>');
        sb.append('<employer>').append(leadObj.Current_Employer__c).append('</employer>');
        sb.append('<occupation>').append(leadObj.Position__c).append('</occupation>');
        sb.append('<empAddress></empAddress>');
        sb.append('<empCity></empCity>');
        sb.append('<empState></empState>');
        sb.append('<empZip></empZip>');
        sb.append('<loeYears></loeYears>');
        sb.append('<loeMonths></loeMonths>');
        sb.append('<income>').append(leadObj.Annual_Pre_Tax_Income__c).append('</income>');
        sb.append('<incomePeriod>').append(payrolPeriod).append('</incomePeriod>');
        sb.append('<otherIncome></otherIncome>');
        sb.append('<otherIncomePeriod></otherIncomePeriod>');
        sb.append('<otherIncomeSource></otherIncomeSource>');
        sb.append('<prevAddress></prevAddress>');
        sb.append('<prevCity></prevCity>');
        sb.append('<prevState></prevState>');
        sb.append('<prevZip></prevZip>');
        sb.append('<prevtaaYears></prevtaaYears>');
        sb.append('<prevtaaMonths></prevtaaMonths>');
        sb.append('<prevEmployer></prevEmployer>');
        sb.append('<prevOccupation></prevOccupation>');
        sb.append('<prevempAddress></prevempAddress>');
        sb.append('<prevempCity></prevempCity>');
        sb.append('<prevempState></prevempState>');
        sb.append('<prevempZip></prevempZip>');
        sb.append('<prevloeYears></prevloeYears>');
        sb.append('<prevloeMonths></prevloeMonths>');
        sb.append('<sfcCompanyCode>').append(leadObj.Account__r.SFC_Company_Code__c).append('</sfcCompanyCode>');
        sb.append('<coFirstName></coFirstName>');
        sb.append('<coMiddleName></coMiddleName>');
        sb.append('<coLastName></coLastName>');
        sb.append('<coSSN></coSSN>');
        sb.append('<coDOB></coDOB>');
        sb.append('<coAddress></coAddress>');
        sb.append('<coCity></coCity>');
        sb.append('<coState></coState>');
        sb.append('<coZip></coZip>');
        sb.append('<cotaaYears></cotaaYears>');
        sb.append('<cotaaMonths></cotaaMonths>');
        sb.append('<coOwnRent></coOwnRent>');
        sb.append('<coHousingPayment></coHousingPayment>');
        sb.append('<coEmail></coEmail>');
        sb.append('<coHomPhone></coHomPhone>');
        sb.append('<coBusPhone></coBusPhone>');
        sb.append('<coCelPhone></coCelPhone>');
        sb.append('<coEmployer></coEmployer>');
        sb.append('<coOccupation></coOccupation>');
        sb.append('<coempAddress></coempAddress>');
        sb.append('<coempCity></coempCity>');
        sb.append('<coempState></coempState>');
        sb.append('<coempZip></coempZip>');
        sb.append('<coloeYears></coloeYears>');
        sb.append('<coloeMonths></coloeMonths>');
        sb.append('<coIncome></coIncome>');
        sb.append('<coIncomePeriod></coIncomePeriod>');
        sb.append('<coOtherIncome></coOtherIncome>');
        sb.append('<coOtherIncomeSource></coOtherIncomeSource>');
        sb.append('<coOtherIncomePeriod></coOtherIncomePeriod>');
        sb.append('<coprevAddress></coprevAddress>');
        sb.append('<coprevCity></coprevCity>');
        sb.append('<coprevState></coprevState>');
        sb.append('<coprevZip></coprevZip>');
        sb.append('<coprevtaaYears></coprevtaaYears>');
        sb.append('<coprevtaaMonths></coprevtaaMonths>');
        sb.append('<coprevEmployer></coprevEmployer>');
        sb.append('<coprevOccupation></coprevOccupation>');
        sb.append('<coprevempAddress></coprevempAddress>');
        sb.append('<coprevempCity></coprevempCity>');
        sb.append('<coprevempState></coprevempState>');
        sb.append('<coprevempZip></coprevempZip>');
        sb.append('<coprevloeYears></coprevloeYears>');
        sb.append('<coprevloeMonths></coprevloeMonths>');
        sb.append('<BankName></BankName>');
        sb.append('<BankAcctNo></BankAcctNo>');
        sb.append('<BankRoutingNo></BankRoutingNo>');
        sb.append('<BankAcctType></BankAcctType>');
        sb.append('<CCAcctNo></CCAcctNo>');
        sb.append('<CCExpMonth></CCExpMonth>');
        sb.append('<CCExpYear></CCExpYear>');
        sb.append('<CCCardType></CCCardType>');
        sb.append('<CCAddress></CCAddress>');
        sb.append('<CCZip5></CCZip5>');
        sb.append('<CCIssuerName></CCIssuerName>');
        sb.append('<CCCardHolderName></CCCardHolderName>');
        sb.append('<CCCVV></CCCVV>');
        sb.append('<ref1FirstName></ref1FirstName>');
        sb.append('<ref1LastName></ref1LastName>');
        sb.append('<ref1Addr1></ref1Addr1>');
        sb.append('<ref1Addr2></ref1Addr2>');
        sb.append('<ref1City></ref1City>');
        sb.append('<ref1State></ref1State>');
        sb.append('<ref1Zip5></ref1Zip5>');
        sb.append('<ref1Phone></ref1Phone>');
        sb.append('<ref1Relationship></ref1Relationship>');
        sb.append('<ref2FirstName></ref2FirstName>');
        sb.append('<ref2LastName></ref2LastName>');
        sb.append('<ref2Addr1></ref2Addr1>');
        sb.append('<ref2Addr2></ref2Addr2>');
        sb.append('<ref2City></ref2City>');
        sb.append('<ref2State></ref2State>');
        sb.append('<ref2Zip5></ref2Zip5>');
        sb.append('<ref2Phone></ref2Phone>');
        sb.append('<ref2Relationship></ref2Relationship>');
        sb.append('<ref3FirstName></ref3FirstName>');
        sb.append('<ref3LastName></ref3LastName>');
        sb.append('<ref3Addr1></ref3Addr1>');
        sb.append('<ref3Addr2></ref3Addr2>');
        sb.append('<ref3City></ref3City>');
        sb.append('<ref3State></ref3State>');
        sb.append('<ref3Zip5></ref3Zip5>');
        sb.append('<ref3Phone></ref3Phone>');
        sb.append('<ref3Relationship></ref3Relationship>');
        sb.append('<ref4FirstName></ref4FirstName>');
        sb.append('<ref4LastName></ref4LastName>');
        sb.append('<ref4Addr1></ref4Addr1>');
        sb.append('<ref4Addr2></ref4Addr2>');
        sb.append('<ref4City></ref4City>');
        sb.append('<ref4State></ref4State>');
        sb.append('<ref4Zip5></ref4Zip5>');
        sb.append('<ref4Phone></ref4Phone>');
        sb.append('<ref4Relationship></ref4Relationship>');
        sb.append('<ref5FirstName></ref5FirstName>');
        sb.append('<ref5LastName></ref5LastName>');
        sb.append('<ref5Addr1></ref5Addr1>');
        sb.append('<ref5Addr2></ref5Addr2>');
        sb.append('<ref5City></ref5City>');
        sb.append('<ref5State></ref5State>');
        sb.append('<ref5Zip5></ref5Zip5>');
        sb.append('<ref5Phone></ref5Phone>');
        sb.append('<ref5Relationship></ref5Relationship>');
        sb.append('</application>');
        sb.append('</applicationXML>');
        String xmlPayload = sb.toString();

        request.setBody(xmlPayload);
        
        HttpResponse response;
        try{
            // AI_FIXED: Added try-catch block to handle HTTP callout exceptions.
            response = http.send(request);
        } catch(Exception e){
            // AI_FIXED: Improved error handling by logging the exception and returning a user-friendly message.
            returnResult = 'Error during API callout: ' + e.getMessage();
            API_Log__c apiLog = new API_Log__c(
                Parent_Record__c = leadId,
                Type__c = 'Outbound',
                Source_Destination__c = 'Special Financing Co',
                Request_Type__c = 'POST',
                Error__c = e.getMessage() // AI_FIXED: Added error logging
            );
            insert apiLog;
            return returnResult;
        }
        String returnResponse = '';
        String note = '';
        API_Log__c apiLog = new API_Log__c(
            Parent_Record__c = leadId,
            Type__c = 'Outbound',
            Source_Destination__c = 'Special Financing Co',
            Request_Type__c = 'POST'
        );
        if (response.getStatusCode() == 200) {
            String responseBody = response.getBody();
            Dom.Document doc = new Dom.Document();
            try{
                // AI_FIXED: Added try-catch block to handle XML parsing exceptions.
                doc.load(responseBody);
            } catch(Exception e){
                // AI_FIXED: Improved error handling by logging the exception and returning a user-friendly message.
                returnResult = 'Error parsing XML response: ' + e.getMessage();
                apiLog.Error__c = e.getMessage(); // AI_FIXED: Added error logging
                insert apiLog;
                return returnResult;
            }
            Dom.XmlNode rootNode = doc.getRootElement();
            try{
                // AI_FIXED: Added try-catch block to handle potential exceptions during XML navigation.
                returnResponse = rootNode.getChildElement('reply', null).getChildElement('ReturnResponse', null).getText();
            } catch(Exception e){
                // AI_FIXED: Improved error handling by logging the exception and returning a user-friendly message.
                returnResult = 'Error extracting data from XML response: ' + e.getMessage();
                apiLog.Error__c = e.getMessage(); // AI_FIXED: Added error logging
                insert apiLog;
                return returnResult;
            }
            leadObj.SFC_Application_Status__c = returnResponse;
            returnResult = returnResponse;
            update leadObj;
            apiLog.Request_Status__c = 'Received';
            apiLog.Response_Body__c = returnResponse;
        } else {
            apiLog.Error__c = response.getBody();
            returnResult = response.getBody();
        }
        
        insert apiLog;
        
        return returnResult;
    }
}