@isTest
public class CreateAccAndContactForGA_Test {
	
    @isTest
    static void testQuery() {
        // Create a Guaranteed_Approval_Application__c record for testing
        Guaranteed_Approval_Application__c gaObj = new Guaranteed_Approval_Application__c(
            Corporate_Business_Name__c = 'Test Business Test',
            Company_Website__c = 'http://www.example.com',
            Been_In_Business_Years__c = 3, // Example value
            Number_of_Sales_Agent__c = 5, // Example value
            Total_Sales_For_2023__c = 100000, // Example value
            Address__c = '123 Main St', // Example value
            City__c = 'City', // Example value
            //State__c = 'California', // Example value
            Zip__c = '12345', // Example value
            Principal_Name_1__c = 'John Doe Test', // Example value
            Company_Email__c = 'test@example.com' // Example value
            // Add values for other fields here
        );
        insert gaObj;
        
        CreateAccAndContactForGA.createAccConRecord(gaObj.Id);
    }

    @isTest
    static void testQuery1() {

        Account client = new Account( name = 'Test Business Test', Client_code__c = '12345678' );
        insert client;

        // Create a Guaranteed_Approval_Application__c record for testing
        Guaranteed_Approval_Application__c gaObj = new Guaranteed_Approval_Application__c(
            Corporate_Business_Name__c = 'Test Business Test',
            Company_Website__c = 'http://www.example.com',
            Been_In_Business_Years__c = 3, // Example value
            Number_of_Sales_Agent__c = 5, // Example value
            Total_Sales_For_2023__c = 100000, // Example value
            Address__c = '123 Main St', // Example value
            City__c = 'City', // Example value
            //State__c = 'California', // Example value
            Zip__c = '12345', // Example value
            Principal_Name_1__c = 'John', // Example value
            Company_Email__c = 'test@example.com' // Example value
            // Add values for other fields here
        );
        insert gaObj;
        
        CreateAccAndContactForGA.createAccConRecord(gaObj.Id);
    }
}