@isTest
private class GenerateGA_PDF_Test {
    @isTest
    static void testGeneratePDF() {
        // Create test data
        Guaranteed_Approval_Application__c obj = new Guaranteed_Approval_Application__c();
        // Set the necessary fields on the object
        // ...

        insert obj;

        // Set the current page reference to your Visualforce page
        PageReference pageRef = Page.GA_DataConfirmation;
        Test.setCurrentPage(pageRef);

        // Call the method to be tested
        Test.startTest();
        List<String> recordIdName = new List<String>();
        recordIdName.add(obj.Id + ',' + obj.Name); // Add the record ID and name to the list
        GenerateGA_PDF.generatePDF(recordIdName);
        Test.stopTest();

        // Perform assertions or verifications
        // Verify that the PDF was created and attached
        Attachment attachment = [SELECT Id FROM Attachment WHERE ParentId = :obj.Id];
        System.assertNotEquals(null, attachment); // Assert that the attachment is not null

        // Verify any other expected behavior or outcomes
        // ...
    }
}