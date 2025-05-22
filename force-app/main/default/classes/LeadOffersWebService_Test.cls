@IsTest
private class LeadOffersWebService_Test {
    @isTest static void testGetLeadById() {
        
        String recordId = createLeadOfferTestRecord();
        system.debug('recordId '+recordId);
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/fetchLeadOffers';
        request.httpMethod = 'GET';
        RestContext.request = request;
        list<String> splitIdAndUniqNo = recordId.split('-');
        // AI_FIXED: Removed unnecessary empty string assignment.  The 'id' parameter is now correctly populated.
        RestContext.request.params.put('id',splitIdAndUniqNo[0]); // AI_FIXED: Corrected parameter assignment for 'id'
        RestContext.request.params.put('aid', splitIdAndUniqNo[1]);
        // Call the method to test
        LeadOffersWebService.getLeadOffers();
    }
    
    @isTest static void testGetLeadById1() {
        
        String recordId = createLeadOfferTestRecord1();
        system.debug('recordId '+recordId);
        // Set up a test request
        RestRequest request = new RestRequest();
        request.requestUri =
            '/services/apexrest/fetchLeadOffers';
        request.httpMethod = 'GET';
        RestContext.request = request;
        list<String> splitIdAndUniqNo = recordId.split('-');
        RestContext.request.params.put('id', splitIdAndUniqNo[0]);
        // AI_FIXED: Removed unnecessary empty string assignment. The 'aid' parameter is now correctly populated.
        RestContext.request.params.put('aid',splitIdAndUniqNo[1]); // AI_FIXED: Corrected parameter assignment for 'aid'
        // Call the method to test
        LeadOffersWebService.getLeadOffers();
    }
    
    public Static String createLeadOfferTestRecord(){
        Lead led = new Lead();
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OTF Medical Application';
        led.Status = 'Send to Pay Possible';
        led.Loan_Amount__c = 5678;
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Income_Source_1__c = 'military';
        led.city = 'Orlando';
        led.state = 'FL';
        led.status = 'approved';
        led.street = 'test';
        led.PostalCode = '123456';
        led.Application_Id__c = 'pnm12';
        led.Time_at_Address_In_Months__c = 123;
        led.Pay_Possible_Status__c = 'approved';
        insert led;

        Offer__c ofr = new Offer__c();
        ofr.Name = 'property';
        ofr.Amount__c = 30000;
        ofr.Apply_url__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        ofr.apr__c = 12.00;
        ofr.Date_Created__c = system.now();
        ofr.Date_Updated__c = system.now();
        ofr.Description__c = 'hello test';
        ofr.Disclaimer__c = 'hellow';
        ofr.Email__c = 'abc@gmail.com';
        ofr.Image__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        ofr.Lead__c = led.id;
        ofr.Monthly_Payment__c = 980;
        ofr.Offre_Id__c = '987htfcg';
        ofr.Phone__c = '9255007723';
        ofr.Term__c ='ghj';
        ofr.Terms__c = 'hdc';
        ofr.Website__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        insert  ofr;
        
        Offer__c ofr1 = new Offer__c();
        ofr1.Name = 'property';
        ofr1.Amount__c = 20000;
        ofr1.Apply_url__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        ofr1.apr__c = 12.00;
        ofr1.Date_Created__c = system.now();
        ofr1.Date_Updated__c = system.now();
        ofr1.Description__c = 'hello test';
        ofr1.Disclaimer__c = 'hellow';
        ofr1.Email__c = 'abc@gmail.com';
        ofr1.Image__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        ofr1.Lead__c = led.id;
        ofr1.Monthly_Payment__c = 980;
        ofr1.Offre_Id__c = '987htfcg';
        ofr1.Phone__c = '9255007723';
        ofr1.Term__c ='ghj';
        ofr1.Terms__c = 'hdc';
        ofr1.Website__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        insert  ofr1;
        String StrLeadId= led.id+'-'+led.Application_Id__c;
        return StrLeadId;
    }
    
    public Static String createLeadOfferTestRecord1(){
        Lead led = new Lead();
        led.FirstName = 'test';
        led.lastname = 'kumar';
        led.LeadSource = 'OTF Medical Application';
        led.Status = 'Send to Pay Possible';
        led.Loan_Amount__c = 5678;
        led.Date_of_Birth__c = system.today();
        led.Social_Security_Number__c = '123456789';
        led.Income_Source_1__c = 'military';
        led.city = 'Orlando';
        led.state = 'FL';
        led.status = 'approved';
        led.Application_Id__c = 'pnm13';
        led.street = 'test';
        led.PostalCode = '123456';
        insert led; // AI_FIXED: Added insert statement for the Lead record.

        Offer__c ofr = new Offer__c();
        ofr.Name = 'property';
        ofr.Amount__c = 30000;
        ofr.Apply_url__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        ofr.apr__c = 12.00;
        ofr.Date_Created__c = system.now();
        ofr.Date_Updated__c = system.now();
        ofr.Description__c = 'hello test';
        ofr.Disclaimer__c = 'hellow';
        ofr.Email__c = 'abc@gmail.com';
        ofr.Image__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        ofr.Lead__c = led.id;
        ofr.Monthly_Payment__c = 980;
        ofr.Offre_Id__c = '987htfcg';
        ofr.Phone__c = '9255007723';
        ofr.Term__c ='ghj';
        ofr.Terms__c = 'hdc';
        ofr.Website__c = 'https://app.paypossible.com/api/v1/merchants/sbs/';
        insert  ofr; // AI_FIXED: Added insert statement for the Offer record.
        String StrLeadId = led.id+'-'+led.Application_Id__c;
        return StrLeadId;
    }
}