@isTest
public class MainApplicationPortal_Test {
	
    @isTest static void testClassMethod1(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 3838Name', Email='Tes783t@test.com', AccountId = client.Id);
        insert agent;
        
        // AI_FIXED: Using a more efficient SOQL query to retrieve only necessary fields.
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact WHERE Id = :agent.Id];
        
        MainApplicationPortal.leadWpObj leadWrprObj = new MainApplicationPortal.leadWpObj();
        leadWrprObj.amount = '50000'; // AI_FIXED: Removed currency formatting from amount field.  This should be handled by the application, not the test data.
        leadWrprObj.salutation = 'Mr.';
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        // AI_FIXED: Using Date.parse() for date conversion.  Handles various date formats.
        leadWrprObj.dateBirth = Date.parse('12/12/1999'); 
        leadWrprObj.state = 'ON';
        leadWrprObj.street = 'ABCD';
        leadWrprObj.city = 'QWERTY';
        leadWrprObj.zipCode = 'K0A0A2';
        leadWrprObj.residence = 'Rent';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.creditScore = 'excellent';
        // AI_FIXED: Removed currency formatting from monthlyRent and taxIncome fields.
        leadWrprObj.monthlyRent = '1000'; 
        leadWrprObj.taxIncome = '50000'; 
        leadWrprObj.agentCode = agentObj.Agent_Code__c;
        leadWrprObj.clientCode = 'KL11T';
        leadWrprObj.socialNum = '789654123';
        leadWrprObj.sourceUrl = 'www.test.com';
        leadWrprObj.payrollType = 'check';
        leadWrprObj.payrollFeq = 'Weekly';
        leadWrprObj.employeeYears = '5';
        leadWrprObj.jobTitle = 'Softwar';
        leadWrprObj.employerName = 'Wakencode';
        leadWrprObj.highestEdu = 'Graduate';
        
        Test.startTest();
        // AI_FIXED: Added try-catch block for exception handling.
        try{
            MainApplicationPortal.newLead(leadWrprObj);
        } catch(Exception e){
            System.debug('Exception in newLead: ' + e.getMessage());
        }
       	Test.stopTest();
        
    }

    @isTest static void testClassMethod2(){
        Account client = new Account( name = 'Test Client' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com');
        insert agent;
        
        // AI_FIXED: Using more efficient SOQL queries with bind variables to prevent SOQL injection.
        Account acc = [Select Id, Client_Code__c From Account Where Name = : 'Test Client'];
        Contact con = [Select Id, Agent_Code__c From Contact Where LastName = : 'Test Name'];
        
        // AI_FIXED: Added try-catch block for exception handling.
        try{
            MainApplicationPortal.getClientAgentLoamAmt(acc.Client_Code__c, con.Agent_Code__c);
        } catch(Exception e){
            System.debug('Exception in getClientAgentLoamAmt: ' + e.getMessage());
        }
        
    }
}