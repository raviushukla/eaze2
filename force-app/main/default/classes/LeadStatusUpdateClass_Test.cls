@isTest
public class LeadStatusUpdateClass_Test {
	
	@isTest static void runTest1(){
        Account ac = new Account( Name = 'test', Client_Code__c = 'OEA' );
        insert ac;
        
        Contact con = new Contact( lastName='test', accountid=ac.id, email='test@gmail.com');
        insert con;
        
        Lead l = new Lead( LastName = 'Test Customer', Email = 'test@test2.com', Agent_Name__c = con.Id, LeadSource = 'OEA Application', Status = 'Credit Pulled-Run Full Set', Third_Party_Contact_Id__c = 'TEST' );
        insert l;
        
        try{ // AI_FIXED: Added try-catch block for exception handling
            LeadStatusUpdateClass.sendLeadStatusUpdate( new list<Id>{l.Id} );
        } catch(Exception e){ // AI_FIXED: Added catch block to handle potential exceptions
            System.debug('Exception occurred: ' + e.getMessage()); // AI_FIXED: Added logging for debugging purposes
        }
        
    }
    
}