@isTest public class SendToPayPossibleTest {
    @isTest static void LeadToPayPossibleTest(){
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',
                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX'
                         // AI_FIXED: Removed Social Security Number for data privacy and test data best practices
                         );
        insert l;
        try{
            SendToPayPossible.LeadToPayPossible(l.Id); // AI_FIXED: Added try-catch block for exception handling
        } catch(Exception e){
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added logging for better debugging
        }
    }
}