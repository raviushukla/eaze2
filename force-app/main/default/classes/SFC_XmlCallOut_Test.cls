@isTest
public class SFC_XmlCallOut_Test {
	
    @IsTest
    static void firstMethod(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678', SFC_Password__c = 'SWPWD', SFC_Company_Code__c = 'SWCODE',
                                    SFC_Username__c = 'SWUSER');
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        List<Lead> ldList = new List<Lead>();
        
		date myDate = date.newInstance(1990, 11, 21);
        Lead leadObj = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          Year_at_Address__c = '2',
                          Loan_Amount__c = 10000,
                          Agent_Name__c = agent.Id,
                          State = 'TX',
                          Account__c = client.Id,
                          GA_Lead__c = True,
                          Date_of_Birth__c = myDate,       
                          Declined_or_Closed_Lost_Date__c = Date.today(),
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId());
        insert leadObj;
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new ExampleCalloutMock());
        SFC_XmlCallOut.makeXMLCallout(leadObj.Id);
        Test.stopTest();
    }

    public class ExampleCalloutMock implements HttpCalloutMock{
      public HttpResponse respond(HTTPRequest req){
        HttpResponse res = new HttpResponse();
        res.setStatus('OK');
        res.setStatusCode(200);
        res.setBody('<?xml version="1.0"?><applicationXMLresponse><reply><ReturnResponse>PROCESSED</ReturnResponse><SFCAppNumber></SFCAppNumber></reply><application><applicationNum>AP-0071033</applicationNum><firstName></firstName><midName></midName><lastName></lastName><ssn>856456789</ssn><dob>1/1/1990</dob><address>TEST</address><city>TEST</city><state>AK</state><zip>98798</zip><taaYears>nu</taaYears><taaMonths></taaMonths><ownrent>OWN</ownrent><housingPayment>555.00</housingPayment><email>TEST@TEST.COM</email><homPhone>9879879879</homPhone><busPhone></busPhone><celPhone></celPhone><employer>TEST</employer><occupation>TEST</occupation><empAddress></empAddress><empCity></empCity><empState></empState><empZip></empZip><loeYears></loeYears><loeMonths></loeMonths><income>55.00</income><incomePeriod>WEEKL</incomePeriod><otherIncome>0</otherIncome><otherIncomePeriod></otherIncomePeriod><otherIncomeSource></otherIncomeSource><prevAddress></prevAddress><prevCity></prevCity><prevState></prevState><prevZip></prevZip><prevtaaYears></prevtaaYears><prevtaaMonths></prevtaaMonths><prevEmployer></prevEmployer><prevOccupation></prevOccupation><prevempAddress></prevempAddress><prevempCity></prevempCity><prevempState></prevempState><prevempZip></prevempZip><prevloeYears></prevloeYears><prevloeMonths></prevloeMonths><sfcCompanyCode>SB1234</sfcCompanyCode><coFirstName></coFirstName><coMiddleName></coMiddleName><coLastName></coLastName><coSSN></coSSN><coDOB></coDOB><coAddress></coAddress><coCity></coCity><coState></coState><coZip></coZip><cotaaYears></cotaaYears><cotaaMonths></cotaaMonths><coOwnRent></coOwnRent><coHousingPayment>0</coHousingPayment><coEmail></coEmail><coHomPhone></coHomPhone><coBusPhone></coBusPhone><coCelPhone></coCelPhone><coEmployer></coEmployer><coOccupation></coOccupation><coempAddress></coempAddress><coempCity></coempCity><coempState></coempState><coempZip></coempZip><coloeYears></coloeYears><coloeMonths></coloeMonths><coIncome></coIncome><coIncomePeriod></coIncomePeriod><coOtherIncome></coOtherIncome><coOtherIncomePeriod></coOtherIncomePeriod><coOtherIncomeSource></coOtherIncomeSource><coprevAddress></coprevAddress><coprevCity></coprevCity><coprevState></coprevState><coprevZip></coprevZip><coprevtaaYears></coprevtaaYears><coprevtaaMonths></coprevtaaMonths><coprevEmployer></coprevEmployer><coprevOccupation></coprevOccupation><coprevempAddress></coprevempAddress><coprevempCity></coprevempCity><coprevempState></coprevempState><coprevempZip></coprevempZip><coprevloeYears></coprevloeYears><coprevloeMonths></coprevloeMonths><BankName></BankName><BankAcctNo></BankAcctNo><BankRoutingNo></BankRoutingNo><BankAcctType></BankAcctType><CCAcctNo></CCAcctNo><CCExpMonth></CCExpMonth><CCExpYear></CCExpYear><CCCardType></CCCardType><CCAddress></CCAddress><CCZip5></CCZip5><CCIssuerName></CCIssuerName><CCCardHolderName></CCCardHolderName><CCCVV></CCCVV><ref1FirstName></ref1FirstName><ref1LastName></ref1LastName><ref1Addr1></ref1Addr1><ref1Addr2></ref1Addr2><ref1City></ref1City><ref1State></ref1State><ref1Zip5></ref1Zip5><ref1Phone></ref1Phone><ref1Relationship></ref1Relationship><ref2FirstName></ref2FirstName><ref2LastName></ref2LastName><ref2Addr1></ref2Addr1><ref2Addr2></ref2Addr2><ref2City></ref2City><ref2State></ref2State><ref2Zip5></ref2Zip5><ref2Phone></ref2Phone><ref2Relationship></ref2Relationship><ref3FirstName></ref3FirstName><ref3LastName></ref3LastName><ref3Addr1></ref3Addr1><ref3Addr2></ref3Addr2><ref3City></ref3City><ref3State></ref3State><ref3Zip5></ref3Zip5><ref3Phone></ref3Phone><ref3Relationship></ref3Relationship><ref4FirstName></ref4FirstName><ref4LastName></ref4LastName><ref4Addr1></ref4Addr1><ref4Addr2></ref4Addr2><ref4City></ref4City><ref4State></ref4State><ref4Zip5></ref4Zip5><ref4Phone></ref4Phone><ref4Relationship></ref4Relationship><ref5FirstName></ref5FirstName><ref5LastName></ref5LastName><ref5Addr1></ref5Addr1><ref5Addr2></ref5Addr2><ref5City></ref5City><ref5State></ref5State><ref5Zip5></ref5Zip5><ref5Phone></ref5Phone><ref5Relationship></ref5Relationship></application></applicationXMLresponse>');
        return res;
      }
    }
}