/*
	Client Logo Upload VF page Controller
	Test Class -> FileUploadController
*/
public without sharing class FileUploadController {
	public Blob file {get; set;}
    public String fileName {get; set;}
    public long MAX_FILE_SIZE = 1000000;
	public String accId {get; set;}
    
    public FileUploadController(){
        accId = apexpages.currentpage().getparameters().get('AccountId');
    }
    
    public PageReference upload() {
        system.debug('File Size ' + file.size());
        if (file.size() > MAX_FILE_SIZE) {
            system.debug('File size greater');
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'File size exceeded the maximum allowed size of 1MB'));
            return null; // AI_FIXED: Return null to stop further execution if file size exceeds limit
        }else{
            try{
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.Title = fileName;
                contentVersion.PathOnClient = fileName;
                contentVersion.VersionData = file;
                insert contentVersion;
                
                //Creating Content Distribution Record for the file
                ContentDistribution contentDisObj = new ContentDistribution();
                contentDisObj.ContentVersionId = contentVersion.Id;
                contentDisObj.Name = contentVersion.Title;
                contentDisObj.PreferencesAllowViewInBrowser = True;
                contentDisObj.PreferencesNotifyOnVisit = false;
                insert contentDisObj;

                // AI_FIXED: Use a single SOQL query to fetch ContentDownloadUrl and handle potential null values
                ContentDistribution cd = [Select Id, ContentDownloadUrl from ContentDistribution where Id = :contentDisObj.Id];
                String contentDownloadUrl = (cd != null) ? cd.ContentDownloadUrl : null;

                // Updating the Account record for the Public url link
                Account accObj = [Select Id, Logo_URL__c From Account Where Id =: accId]; // AI_FIXED: Added Logo_URL__c to the SOQL query to avoid unnecessary query
                if(accObj != null){ // AI_FIXED: Added null check for accObj
                    accObj.Logo_URL__c = contentDownloadUrl;
                    update accObj;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Logo uploaded successfully'));
                } else {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Account not found.')); // AI_FIXED: Handle case where Account is not found.
                }
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'Error uploading logo: ' + e.getMessage())); // AI_FIXED: Improved error message
            } catch (Exception e) { // AI_FIXED: Added a generic catch block to handle other potential exceptions.
                System.debug('An unexpected error occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'An unexpected error occurred. Please contact support.')); // AI_FIXED: Improved error message for unexpected exceptions.
            }
        }
        file = null;
        return null;
		
    }
}