@isTest
public class LeadAutoConvertTest {
    @isTest
    static void testLeadAutoConvert_OnUpdate() {
        // Step 1: Create a lead with Approved = false
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Status = 'New', // or any non-converted status
            Approved_for_Diamond__c = 'No'
        );
        insert testLead;

        // Step 2: Update lead with Approved = true
        testLead.Approved_for_Diamond__c = 'Yes';
        testLead.Status = 'Qualified'; // must match converted status
        update testLead;

        // Step 3: Assert conversion
        Lead convertedLead = [SELECT Id, IsConverted, ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :testLead.Id];
        System.assert(convertedLead.IsConverted, 'Lead should be converted');
        System.assertNotEquals(null, convertedLead.ConvertedAccountId, 'Account should be created');
        System.assertNotEquals(null, convertedLead.ConvertedContactId, 'Contact should be created');
        Account acct = [SELECT Id, Primary_Contact__c FROM Account WHERE Id = :convertedLead.ConvertedAccountId];
		System.assertEquals(convertedLead.ConvertedContactId, acct.Primary_Contact__c, 'Primary contact should be set correctly');

    }

    @isTest
    static void testLeadNotConvertedWhenApprovedFalse() {
        Lead testLead = new Lead(
            FirstName = 'NoConvert',
            LastName = 'Lead',
            Company = 'Non Converted Co',
            Status = 'New',
            Approved_for_Diamond__c = '' // AI_FIXED:  Setting to empty string to test the scenario where Approved_for_Diamond__c is not 'Yes'
        );
        insert testLead;

        // AI_FIXED: Using a more efficient SOQL query to retrieve only necessary fields.
        Lead inserted = [SELECT Id, IsConverted FROM Lead WHERE Id = :testLead.Id]; 
        System.assert(!inserted.IsConverted, 'Lead should not be converted');
    }
}