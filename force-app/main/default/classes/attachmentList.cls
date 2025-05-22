public class attachmentList {
    @AuraEnabled
    public static Network currentSitePrefix(){
        if (Network.getNetworkId() != null) {
            return [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :Network.getNetworkId()];
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static Object fetchAttachments(String recordId){
        List<Attachment> attList = new List<Attachment>();
        for(Attachment att: [Select Name, ParentId From Attachment Where ParentId =: recordId]){
            String fileName = att.Name.toLowerCase();
            if(fileName.contains('clientlogo') || fileName.contains('client logo')){
                attList.add(att);
            }
        }
        return attList;
    }
    @AuraEnabled
    public static Object deteteAttachment(String recordId, String attchId){
        Delete new Attachment(Id=attchId);
        return fetchAttachments(recordId);
    }
}