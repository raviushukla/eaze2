@isTest public class GetOfferFromPayPossibleTest {
    @isTest static void offerFromPayPossibleTest(){
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',
                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX',
                          Social_Security_Number__c = '121-322-434' );
        insert l;
        GetOfferFromPayPossible.offerFromPayPossible(l.Id);
        GetOfferFromPayPossible.offerFromPayPossible('');
    }
}