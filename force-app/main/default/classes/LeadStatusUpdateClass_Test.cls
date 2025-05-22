@isTest
public class LeadStatusUpdateClass_Test {
	
	testmethod static void runTest1(){
        Account ac = new Account( Name = 'test', Client_Code__c = 'OEA' );
        insert ac;
        
        Contact con = new Contact( lastName='test', accountid=ac.id, email='test@gmail.com');
        insert con;
        
        Lead l = new Lead( LastName = 'Test Customer', Email = 'test@test2.com', Agent_Name__c = con.Id, LeadSource = 'OEA Application', Status = 'Credit Pulled-Run Full Set', Third_Party_Contact_Id__c = 'TEST' );
        insert l;
        
        LeadStatusUpdateClass.sendLeadStatusUpdate( new list<Id>{l.Id} );
        
    }
    
}