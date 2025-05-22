@isTest
public class sendMeetingReminder_Test {
    @isTest static void testMthod(){
        Contact agent = new Contact(LastName = 'Test Name',
                                    Email='Test@test.com', 
                                    Agent_Code__c = '111111');
        INSERT agent;
        Lead objLead = new Lead(LastName = 'Test Lead',
                                Date_of_Birth__c = date.today(),
                                LeadSource = 'Other',
                                Status = 'Pre-Approved Pending Income Verification',
                                Social_Security_Number__c = '12',
                                Agent_Name__c = agent.Id,
                                Income_Source_1__c = 'Military',
                                Is_Meeting_Scheduled__c = false,
                                Email = 'Test@test.com',
                                Loan_Amount__c = 123);
        INSERT objLead;
        
        Test.startTest(); 
        sendMeetingReminder sh1 = new sendMeetingReminder();
        String sch = '0 0 23 * * ?'; 
        system.schedule('Test', sch, sh1); 
        Test.stopTest(); 
    }
}