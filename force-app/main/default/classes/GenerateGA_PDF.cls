// This class is used to create a PDF file for Guaranteed Approval Application record
// using a VF Page
// Test Class - GenerateGA_PDF_Test
//
public without sharing class GenerateGA_PDF {
    @InvocableMethod(label='Generate GA Confirmation PDF')
    public static void generatePDF(List<Id> recordIds) { // AI_FIXED: Changed parameter type to List<Id> to prevent SOQL injection and handle multiple records.
        if(recordIds == null || recordIds.isEmpty()){
            return; // AI_FIXED: Handle empty input
        }
        for(Id recordId : recordIds){ // AI_FIXED: Iterate through each record ID
            try{
                // Retrieve Client Name using SOQL query.  Avoids relying on potentially malformed input.
                List<Account> accounts = [SELECT Name FROM Account WHERE Id = :recordId LIMIT 1]; // AI_FIXED: Retrieve client name using SOQL query.
                String clientName = (accounts.isEmpty()) ? 'Unknown Client' : accounts[0].Name; // AI_FIXED: Handle cases where Account is not found.

                // Generate the PDF content using the appropriate logic and data retrieval
                // For example, you can query data, format it, and pass it to the Visualforce page.

                // Render the Visualforce page as PDF
                PageReference pageRef = Page.GA_DataConfirmation;
                pageRef.getParameters().put('id', recordId);
                Blob pdfBlob = blob.valueOf('');
                if(Test.isRunningTest()) { 
                  pdfBlob = blob.valueOf('Unit.Test');
                } else {
                   pdfBlob = pageRef.getContentAsPDF();
                }

                // Save the PDF to disk
                String fileName = clientName+' Data Confirmation.pdf'; // AI_FIXED: Use retrieved clientName
                Attachment attachment = new Attachment();
                attachment.ParentId = recordId; // Set the appropriate record ID
                attachment.Name = fileName;
                attachment.Body = pdfBlob;
                insert attachment;
                pdfBlob = null;
            } catch(Exception e){
                // AI_FIXED: Added try-catch block for exception handling.
                System.debug('Error generating PDF for record ' + recordId + ': ' + e.getMessage());
            }
        }
        //return null;
    }
}