public class filePreviewAndDownloadController {
    @AuraEnabled(cacheable=true)
    public static List<fileWrapper> getRelatedFilesByRecordId(String recordId) {
        List<fileWrapper> fileWrapperList = new List<fileWrapper>();
        // AI_FIXED: Added try-catch block for exception handling and improved SOQL query for better performance.
        try {
            // AI_FIXED: Using a single SOQL query to fetch necessary data.
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title , CreatedDate, ContentDocument.Title FROM ContentVersion WHERE ContentDocumentId IN (SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId) AND Oasis_Instant_Approval__c = True];
            for (ContentVersion docLink : docs) {
                fileWrapperList.add(new fileWrapper(docLink.ContentDocumentId, docLink.Title, docLink.CreatedDate.format('yyyy-MM-dd h:mm a')));
            }
        } catch (Exception e) {
            // AI_FIXED: Added logging for better debugging.  Consider more robust error handling in production.
            System.debug('Error retrieving files: ' + e.getMessage());
        }
        return fileWrapperList;
    }

    public class fileWrapper{
        @AuraEnabled
        public String docId {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String createdDate {get;set;}

        public fileWrapper(String docId, String title, String createdDate){
            this.docId = docId;
            this.title = title;
            this.createdDate = createdDate;
        }
    }    
}