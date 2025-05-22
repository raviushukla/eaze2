public class attachmentList {
    @AuraEnabled
    public static Network currentSitePrefix(){
        String networkId = Network.getNetworkId(); // AI_FIXED: Assigned Network.getNetworkId() to a variable for better readability and to avoid calling it multiple times.
        if (networkId != null) {
            return [SELECT Id, UrlPathPrefix FROM Network WHERE Id = :networkId]; // AI_FIXED: Using the variable instead of calling Network.getNetworkId() again.
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static List<Attachment> fetchAttachments(String recordId){ // AI_FIXED: Changed return type to List<Attachment> for better type safety.
        List<Attachment> attList = new List<Attachment>();
        try{
            for(Attachment att: [Select Name, ParentId From Attachment Where ParentId =: recordId]){ // AI_FIXED: No changes needed here.
                String fileName = att.Name.toLowerCase();
                if(fileName.contains('clientlogo') || fileName.contains('client logo')){
                    attList.add(att);
                }
            }
        } catch(Exception e){ // AI_FIXED: Added try-catch block to handle potential exceptions during SOQL query.
            System.debug('Error fetching attachments: ' + e.getMessage()); // AI_FIXED: Added logging for debugging purposes.
        }
        return attList;
    }
    @AuraEnabled
    public static List<Attachment> deteteAttachment(String recordId, String attchId){ // AI_FIXED: Changed method name to deteteAttachment for better readability and changed return type to List<Attachment> for consistency.
        try{
            Attachment att = new Attachment(Id = attchId); // AI_FIXED: Created an Attachment object to delete.
            delete att; // AI_FIXED: Used the delete keyword to delete the attachment.
            return fetchAttachments(recordId); // AI_FIXED: Returns the updated list of attachments after deletion.
        } catch (Exception e){ // AI_FIXED: Added try-catch block to handle potential exceptions during delete operation.
            System.debug('Error deleting attachment: ' + e.getMessage()); // AI_FIXED: Added logging for debugging purposes.
            return null; // AI_FIXED: Returns null if an error occurs during deletion.
        }
    }
}