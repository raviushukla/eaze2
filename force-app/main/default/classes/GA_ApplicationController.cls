// This class is used for the VF Page - GA_DataConfirmation
// To generate a PDF
// Test Class - GA_ApplicationController_Test
public without sharing class GA_ApplicationController {
	public Guaranteed_Approval_Application__c GA_Application { get; set; }

    public GA_ApplicationController() {
        // Query the record data based on your logic (e.g., record ID, criteria)
        // Assuming you have the record ID available, you can query it as follows:
        String recordId = ApexPages.currentPage().getParameters().get('id');
        GA_Application = [SELECT Id, Form_Filled_Date__c, Date_Company_Established__c, Corporate_Business_Name__c, DBA__c,Company_Website__c, Address__c,
                                City__c, State__c, Zip__c, Phone__c, Company_Email__c,
                                Property_Owned_by_or_Landlord_Name__c, Property_Owner_Address__c, Property_Owner_Phone__c,
                                Principal_Name_1__c, Principal_Name_2__c, Principal_1_Title__c,
                                Principal_2_Title__c, Principal_Address_1__c, Principal_Address_2__c,
                                Principal_Phone_1__c, Principal_Phone_2__c, Principal_1_SS__c,
                                Principal_2_SS__c, Bank_Name__c,Account_Number__c,Bank_Routing__c,Video_Confirmation__c,
                                Bank_City__c, Bank_State__c, Bank_Phone__c, Bank_Contact__c, Current_Revenue_Per_Month__c,
                                Average_Requested_Amount__c, Financing_Request_Per_Week__c, Service_Product_Description__c
                            FROM Guaranteed_Approval_Application__c WHERE Id =:recordId];
    }
}