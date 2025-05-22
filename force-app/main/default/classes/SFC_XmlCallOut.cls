//	Sendin the Lead data to the SFC end point
//	This class is called from the Lwc cmp (sendGaLeadToSfcLwc), which as further called from VF page
//	Test class SFC_XmlCallOut_Test
public class SFC_XmlCallOut {
    
    @AuraEnabled
    public static String makeXMLCallout(String leadId) {
        String returnResult = '';
        Lead leadObj = [Select Id, FirstName, LastName, MobilePhone, Social_Security_Number__c, Date_of_Birth__c, Street, 
                        City, State, Postalcode, Current_Residence_Status__c, Monthly_Rent_Mortgage_Amount__c,
                        Email, Current_Employer__c, Position__c, Annual_Pre_Tax_Income__c, Payroll_Frequency__c,
                        Year_at_Address__c, Account__r.SFC_Username__c, Account__r.SFC_Password__c, Applicant_SR__c, Account__r.SFC_Company_Code__c
                        From Lead Where Id =: leadId];
        
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
        //request.setHeader('Accept', '*/*');
        //request.setHeader('Content-Type', 'gzip, deflate, br');
        //Blob headerValue = Blob.valueOf(leadObj.Account__r.SFC_Username__c + ':' + leadObj.Account__r.SFC_Password__c);
        //String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
        //request.setHeader('Authorization', authorizationHeader); 
        
        String xmlPayload = 
              '<applicationXML>' +
                '<authentication>' +
                    '<username>'+Label.SFC_Username+'</username>' +
                    '<password>'+Label.SFC_Password+'</password>' +
                '</authentication>' +
                '<application>' +
                    '<applicationNum>'+ leadObj.Applicant_SR__c +'</applicationNum>' +
                    '<firstName>'+leadObj.FirstName+'</firstName>' +
                    '<midName></midName>' +
                    '<lastName>'+leadObj.LastName+'</lastName>' +
                    '<ssn>'+leadObj.Social_Security_Number__c+'</ssn>' +
                    '<dob>'+leadObj.Date_of_Birth__c.format()+'</dob>' +
                    '<address>'+leadObj.Street+'</address>' +
                    '<city>'+leadObj.City+'</city>' +
                    '<state>'+leadObj.State+'</state>' +
                    '<zip>'+leadObj.PostalCode+'</zip>' +
                    '<taaYears>'+leadObj.Year_at_Address__c+'</taaYears>' +
                    '<taaMonths></taaMonths>' +
                    '<ownrent>'+housingStatus+'</ownrent>' +
                    '<housingPayment>'+leadObj.Monthly_Rent_Mortgage_Amount__c+'</housingPayment>' +
                    '<email>'+leadObj.Email+'</email>' +
                    '<homPhone>'+leadObj.MobilePhone+'</homPhone>' +
                    '<busPhone></busPhone>' +
                    '<celPhone></celPhone>' +
                    '<employer>'+leadObj.Current_Employer__c+'</employer>' +
                    '<occupation>'+leadObj.Position__c+'</occupation>' +
                    '<empAddress></empAddress>' +
                    '<empCity></empCity>' +
                    '<empState></empState>' +
                    '<empZip></empZip>' +
                    '<loeYears></loeYears>' +
                    '<loeMonths></loeMonths>' +
                    '<income>'+leadObj.Annual_Pre_Tax_Income__c+'</income>' +
                    '<incomePeriod>'+payrolPeriod+'</incomePeriod>' +
                    '<otherIncome></otherIncome>' +
                    '<otherIncomePeriod></otherIncomePeriod>' +
                    '<otherIncomeSource></otherIncomeSource>' +
                    '<prevAddress></prevAddress>' +
                    '<prevCity></prevCity>' +
                    '<prevState></prevState>' +
                    '<prevZip></prevZip>' +
                    '<prevtaaYears></prevtaaYears>' +
                    '<prevtaaMonths></prevtaaMonths>' +
                    '<prevEmployer></prevEmployer>' +
                    '<prevOccupation></prevOccupation>' +
                    '<prevempAddress></prevempAddress>' +
                    '<prevempCity></prevempCity>' +
                    '<prevempState></prevempState>' +
                    '<prevempZip></prevempZip>' +
                    '<prevloeYears></prevloeYears>' +
                    '<prevloeMonths></prevloeMonths>' +
                    '<sfcCompanyCode>'+leadObj.Account__r.SFC_Company_Code__c+'</sfcCompanyCode>' +
                    '<coFirstName></coFirstName>' +
                    '<coMiddleName></coMiddleName>' +
                    '<coLastName></coLastName>' +
                    '<coSSN></coSSN>' +
                    '<coDOB></coDOB>' +
                    '<coAddress></coAddress>' +
                    '<coCity></coCity>' +
                    '<coState></coState>' +
                    '<coZip></coZip>' +
                    '<cotaaYears></cotaaYears>' +
                    '<cotaaMonths></cotaaMonths>' +
                    '<coOwnRent></coOwnRent>' +
                    '<coHousingPayment></coHousingPayment>' +
                    '<coEmail></coEmail>' +
                    '<coHomPhone></coHomPhone>' +
                    '<coBusPhone></coBusPhone>' +
                    '<coCelPhone></coCelPhone>' +
                    '<coEmployer></coEmployer>' +
                    '<coOccupation></coOccupation>' +
                    '<coempAddress></coempAddress>' +
                    '<coempCity></coempCity>' +
                    '<coempState></coempState>' +
                    '<coempZip></coempZip>' +
                    '<coloeYears></coloeYears>' +
                    '<coloeMonths></coloeMonths>' +
                    '<coIncome></coIncome>' +
                    '<coIncomePeriod></coIncomePeriod>' +
                    '<coOtherIncome></coOtherIncome>' +
                    '<coOtherIncomeSource></coOtherIncomeSource>' +
                    '<coOtherIncomePeriod></coOtherIncomePeriod>' +
                    '<coprevAddress></coprevAddress>' +
                    '<coprevCity></coprevCity>' +
                    '<coprevState></coprevState>' +
                    '<coprevZip></coprevZip>' +
                    '<coprevtaaYears></coprevtaaYears>' +
                    '<coprevtaaMonths></coprevtaaMonths>' +
                    '<coprevEmployer></coprevEmployer>' +
                    '<coprevOccupation></coprevOccupation>' +
                    '<coprevempAddress></coprevempAddress>' +
                    '<coprevempCity></coprevempCity>' +
                    '<coprevempState></coprevempState>' +
                    '<coprevempZip></coprevempZip>' +
                    '<coprevloeYears></coprevloeYears>' +
                    '<coprevloeMonths></coprevloeMonths>' +
                    '<BankName></BankName>' +
                    '<BankAcctNo></BankAcctNo>' +
                    '<BankRoutingNo></BankRoutingNo>' +
                    '<BankAcctType></BankAcctType>' +
                    '<CCAcctNo></CCAcctNo>' +
                    '<CCExpMonth></CCExpMonth>' +
                    '<CCExpYear></CCExpYear>' +
                    '<CCCardType></CCCardType>' +
                    '<CCAddress></CCAddress>' +
                    '<CCZip5></CCZip5>' +
                    '<CCIssuerName></CCIssuerName>' +
                    '<CCCardHolderName></CCCardHolderName>' +
                    '<CCCVV></CCCVV>' +
                    '<ref1FirstName></ref1FirstName>' +
                    '<ref1LastName></ref1LastName>' +
                    '<ref1Addr1></ref1Addr1>' +
                    '<ref1Addr2></ref1Addr2>' +
                    '<ref1City></ref1City>' +
                    '<ref1State></ref1State>' +
                    '<ref1Zip5></ref1Zip5>' +
                    '<ref1Phone></ref1Phone>' +
                    '<ref1Relationship></ref1Relationship>' +
                    '<ref2FirstName></ref2FirstName>' +
                    '<ref2LastName></ref2LastName>' +
                    '<ref2Addr1></ref2Addr1>' +
                    '<ref2Addr2></ref2Addr2>' +
                    '<ref2City></ref2City>' +
                    '<ref2State></ref2State>' +
                    '<ref2Zip5></ref2Zip5>' +
                    '<ref2Phone></ref2Phone>' +
                    '<ref2Relationship></ref2Relationship>' +
                    '<ref3FirstName></ref3FirstName>' +
                    '<ref3LastName></ref3LastName>' +
                    '<ref3Addr1></ref3Addr1>' +
                    '<ref3Addr2></ref3Addr2>' +
                    '<ref3City></ref3City>' +
                    '<ref3State></ref3State>' +
                    '<ref3Zip5></ref3Zip5>' +
                    '<ref3Phone></ref3Phone>' +
                    '<ref3Relationship></ref3Relationship>' +
                    '<ref4FirstName></ref4FirstName>' +
                    '<ref4LastName></ref4LastName>' +
                    '<ref4Addr1></ref4Addr1>' +
                    '<ref4Addr2></ref4Addr2>' +
                    '<ref4City></ref4City>' +
                    '<ref4State></ref4State>' +
                    '<ref4Zip5></ref4Zip5>' +
                    '<ref4Phone></ref4Phone>' +
                    '<ref4Relationship></ref4Relationship>' +
                    '<ref5FirstName></ref5FirstName>' +
                    '<ref5LastName></ref5LastName>' +
                    '<ref5Addr1></ref5Addr1>' +
                    '<ref5Addr2></ref5Addr2>' +
                    '<ref5City></ref5City>' +
                    '<ref5State></ref5State>' +
                    '<ref5Zip5></ref5Zip5>' +
                    '<ref5Phone></ref5Phone>' +
                    '<ref5Relationship></ref5Relationship>' +
                '</application>' +
            '</applicationXML>';

        request.setBody(xmlPayload);
        
        HttpResponse response = http.send(request);
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
            doc.load(responseBody);
            Dom.XmlNode rootNode = doc.getRootElement();
            returnResponse = rootNode.getChildElement('reply', null).getChildElement('ReturnResponse', null).getText();
            leadobj.SFC_Application_Status__c = returnResponse;
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