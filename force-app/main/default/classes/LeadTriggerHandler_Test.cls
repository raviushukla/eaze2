@isTest
public class LeadTriggerHandler_Test {
    @isTest static void leadDelete(){
        List<Lead> lstLead = new List<Lead>();
        for(Integer i=0;i<4;i++){
            Lead objLead = new Lead();
            objLead.LastName = 'Test Lead' + i;
            objLead.Agent_Code__c = 'JAC8S7QVT5';
            objLead.Date_of_Birth__c = date.today();
            objLead.Status = 'New Lead';
            // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
            // AI_FIXED: Removed Income Source as it's not crucial for this test method.
            lstLead.add(objLead);
        }
        if(lstLead.size() > 0){
            insert lstLead; 
        }
        // AI_FIXED: Added delete statement to test lead deletion.
        delete lstLead;
    }
    
    @isTest static void testLeadInsert(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          Year_at_Address__c = '2');
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert l;
        Test.stopTest();
        
    }  
    @isTest static void testLeadInsert_2(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678');
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', Email = 'test@te.com', Company = 'test Company', LeadSource = 'OEA Application', Agent_code__c = '', // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
                         );
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert l;
		Test.stopTest();        
    }  
    
    @isTest static void testLeadInsert_3(){
        Id leadFPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        

        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
            Account client = new Account( name = 'test Company', Client_code__c = '12345678');
            insert client;
            
            Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id);
            insert agent;
            
            client.Primary_Contact__c = agent.Id;
            update client;
            
            Lead leadObj = new Lead(LastName = 'Test Name', Email = 'Test@test.com', Company = 'test Company', LeadSource = 'Waiting List Canada', Agent_code__c = '', // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
                                    RecordTypeId = leadFPRecordTypeId );
            insert leadObj; 
            
            leadObj.Status = 'Canada Founders';
            update leadObj;
            
            Account client1 = new Account( name = 'test Company1', Client_code__c = '124478');
            insert client1;
            
            Contact agent1 = new Contact( LastName = 'Test', Email='Test1@test.com', AccountId = client1.Id);
            insert agent1;
            
            client1.Primary_Contact__c = agent1.Id;
            update client1;
            
            Lead leadObj1 = new Lead(LastName = 'Test', Email = 'Test1@test.com', Company = 'test Company', LeadSource = 'Waiting List Canada', Agent_code__c = '', // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
                                     RecordTypeId = leadFPRecordTypeId );
            insert leadObj1; 
            
            leadObj1.Status = 'Canada Founders';
            update leadObj1;
            
            Account client2 = new Account( name = 'test Company2', Client_code__c = '22578');
            insert client2;
            
            Contact agent2 = new Contact( LastName = 'Test', Email='Test2@test.com', AccountId = client2.Id);
            insert agent2;
            
            client2.Primary_Contact__c = agent2.Id;
            update client2;
            
            Lead leadObj2 = new Lead(LastName = 'Test2', Email = 'Test2@test.com', Company = 'test Company', LeadSource = 'Waiting List Canada', Agent_code__c = '', // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
                                     RecordTypeId = leadFPRecordTypeId );
            insert leadObj2; 
            
            leadObj2.Status = 'Canada Founders';
            update leadObj2;
            

            Account client3 = new Account( Name = 'test Company', Client_code__c = '225478');
            insert client3;
            
            Contact agent3 = new Contact(Firstname ='Test', LastName = 'Test3', Email='Test3@test.com', AccountId = client3.Id);
            insert agent3;
            
            client3.Primary_Contact__c = agent3.Id;
            update client3;
            
            Lead leadObj3 = new Lead(Firstname ='Test' ,LastName = 'Test3', Email = 'Test3@gmail.com', Company = 'test Company3', LeadSource = 'Waiting List Canada', Agent_code__c = '', // AI_FIXED: Removed Social Security Number as it's sensitive data and not needed for testing.
                                     RecordTypeId = leadFPRecordTypeId );
            insert leadObj3; 
            
            leadObj3.Status = 'Canada Founders';
            update leadObj3;
        Test.stopTest();        
        
    } 
    private class RestMock1 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            String respn = '{ "reason": "Field : ze value of type com.crowdnetic.maven.domain.loan.LoanType$Category from String  is not a valid enum entry",'+
                    '"type": "ERROR", "message": "InvalidFormatException"}';
                                
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(respn);
            res.setStatusCode(400);
            return res;
        }
    }
    private class RestMock2 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            String respn = '{"loanId": "3bf8b7f4-6cb1-4b71-b667-12c433e35ea9","loan_url": "/gateway/v1/loans/3bf8b7f4-6cb1-4b71-b667-12c433e35ea9"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(respn);
            res.setStatusCode(200);
            return res;
        }
    }
}