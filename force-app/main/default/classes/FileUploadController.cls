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
        }else{
            
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
            ContentDistribution cd = [Select Id, ContentDownloadUrl from ContentDistribution where Id = :contentDisObj.Id  ];
            // Updating the Account record for the Public url link
            Account accObj = [Select Id From Account Where Id =: accId];
            accObj.Logo_URL__c = cd.ContentDownloadUrl;
            try {
                update accObj;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm, 'Logo uploaded successfully'));
            } catch(DmlException e) {
                System.debug('The following exception has occurred: ' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, 'The following exception has occurred: ' + e.getMessage()));
            }
        }
        file = null;
        return null;
		
    }
}