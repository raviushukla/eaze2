// This class is used to create a PDF file for Guaranteed Approval Application record
// using a VF Page
// Test Class - GenerateGA_PDF_Test
//
public without sharing class GenerateGA_PDF {
    @InvocableMethod(label='Generate GA Confirmation PDF')
    public static void generatePDF(List<String> recordIdName ) {
        String recordId = recordIdName[0].split(',')[0];
        String clientName = recordIdName[0].split(',')[1];
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
        String fileName = clientName+' Data Confirmation.pdf';
        Attachment attachment = new Attachment();
        attachment.ParentId = recordId; // Set the appropriate record ID
        attachment.Name = fileName;
        attachment.Body = pdfBlob;
        insert attachment;
		pdfBlob = null;
        //return null;
    }
}