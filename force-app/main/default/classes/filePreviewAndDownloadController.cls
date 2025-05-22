public class filePreviewAndDownloadController {
    @AuraEnabled(cacheable=true)
        public static List<fileWrapper> getRelatedFilesByRecordId(String recordId) {
            List<fileWrapper> fileWrapperList = new List<fileWrapper>();
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title , CreatedDate
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs AND Oasis_Instant_Approval__c = True];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                fileWrapperList.add(new fileWrapper(docLink.ContentDocumentId, docLink.Title, docLink.CreatedDate.format('yyyy-MM-dd h:mm a')));
                //mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            //return mapIdTitle;
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