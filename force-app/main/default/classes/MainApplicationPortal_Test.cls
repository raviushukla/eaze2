@isTest
public class MainApplicationPortal_Test {
	
    @isTest static void testClassMethod1(){
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 3838Name', Email='Tes783t@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        MainApplicationPortal.leadWpObj leadWrprObj = new MainApplicationPortal.leadWpObj();
        leadWrprObj.amount = '$50,000';
        leadWrprObj.salutation = 'Mr.';
        leadWrprObj.firstName = 'Test';
        leadWrprObj.lastName = 'Lead';
        leadWrprObj.email = 'test@gmail.com';
        leadWrprObj.phone = '1234567890';
        leadWrprObj.dateBirth = '12/12/1999';
        leadWrprObj.state = 'ON';
        leadWrprObj.street = 'ABCD';
        leadWrprObj.city = 'QWERTY';
        leadWrprObj.zipCode = 'K0A0A2';
        leadWrprObj.residence = 'Rent';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.creditScore = 'excellent';
        leadWrprObj.monthlyRent = '$1000';
        leadWrprObj.taxIncome = '$50,000';
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
        MainApplicationPortal.newLead(leadWrprObj);
       	Test.stopTest();
        
    }

    @isTest static void testClassMethod2(){
        Account client = new Account( name = 'Test Client' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com');
        insert agent;
        
        Account acc = [Select Id, Client_Code__c From Account Where Name = 'Test Client'];
        Contact con = [Select Id, Agent_Code__c From Contact Where LastName = 'Test Name'];
        
        MainApplicationPortal.getClientAgentLoamAmt(acc.Client_Code__c, con.Agent_Code__c);
        
    }
}