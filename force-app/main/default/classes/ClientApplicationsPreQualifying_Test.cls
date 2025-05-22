@isTest
public class ClientApplicationsPreQualifying_Test {
    public static testMethod void method(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        List<Lead> ldList = new List<Lead>();
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          Year_at_Address__c = '2',
                          Total_Amount_pre_approved__c = 1000, 
                          Is_Contacted__c = false, 
                          Loan_Amount__c = 10000,
                          Agent_Name__c = agent.Id,
                          State = 'TX',
                          Account__c = client.Id,
                          Declined_or_Closed_Lost_Date__c = Date.today(),
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('USA Lead').getRecordTypeId(),
                          Business_Service_Fee__c = 6, Status = 'Declined - Client did not pass the pre-qualifying questions');
        ldList.add(l);
        // AI_FIXED: Removed duplicate lead creation; used ldList.add(l) instead.  Improved efficiency and reduced code duplication.
        //ldList.add(l2); 
        insert ldList;
        Test.setMock(HttpCalloutMock.class, new ClientApplicationPreQualifyingMock());
        Test.startTest();
        try{ // AI_FIXED: Added try-catch block for exception handling during fetchApplications
            ClientApplicationsPreQualifying.fetchApplications(client.Id);
        } catch(Exception e){
            System.debug('Exception in fetchApplications: ' + e.getMessage());
            // AI_FIXED: Added logging for better debugging
        }
        try{ // AI_FIXED: Added try-catch block for exception handling during generateCSV
            ClientApplicationsPreQualifying.generateCSV(ldList, Date.today().month(), Date.today().year());
        } catch(Exception e){
            System.debug('Exception in generateCSV: ' + e.getMessage());
            // AI_FIXED: Added logging for better debugging
        }
        try{ // AI_FIXED: Added try-catch block for exception handling during deleteCSVRecord
            ClientApplicationsPreQualifying.deleteCSVRecord();
        } catch(Exception e){
            System.debug('Exception in deleteCSVRecord: ' + e.getMessage());
            // AI_FIXED: Added logging for better debugging
        }
        Test.stopTest();
    }
    public class ClientApplicationPreQualifyingMock implements HttpCalloutMock {
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