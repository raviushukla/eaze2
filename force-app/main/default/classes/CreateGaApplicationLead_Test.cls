@isTest
public  class CreateGaApplicationLead_Test {

    testmethod static void newGALead() {
        Account client = new Account( name = 'Test Client', Client_code__c = 'KL11T' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test 3838Name', Email='Tes783t@test.com', AccountId = client.Id);
        insert agent;
        
        Contact agentObj = [SELECT Id, Agent_Code__c FROM Contact Where Id =: agent.Id];
        
        CreateGaApplicationLead.leadWpObj leadWrprObj = new CreateGaApplicationLead.leadWpObj();
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
        leadWrprObj.sourceUrl = 'https://eazeconsulting--wncdev4.sandbox.my.salesforce-sites.com/guaranteeApproval?cl=126VG&ag=MDEFQH98O9';
        leadWrprObj.payrollFeq = 'Weekly';
        leadWrprObj.payrollType = 'direct_deposit';
        leadWrprObj.employeeYears = '6-12 Months';
        leadWrprObj.employerName = 'Name';
        leadWrprObj.employment = 'Employed';
        leadWrprObj.jobTitle = 'title';

        Test.startTest();
        CreateGaApplicationLead.newGaLead(leadWrprObj);
       	Test.stopTest();
    }
}