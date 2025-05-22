public class AttachmentTriggerHelper {
    public static void updateTrainingLinkOnContact(List<Attachment> TriggerNew){
        Map<Id, Contact> conMap = new Map<Id, Contact>(); // AI_FIXED: Changed List to Map for better performance
        Set<Id> contactIds = new Set<Id>(); // AI_FIXED: Created a Set to avoid duplicate queries

        for(Attachment attchmnt : TriggerNew){
            contactIds.add(attchmnt.ParentId); // AI_FIXED: Added ParentId to Set for querying Contacts only once
        }

        if(!contactIds.isEmpty()){ // AI_FIXED: Added check to prevent unnecessary SOQL query
            List<Contact> contacts = [SELECT Id, Training_Main_Document_Id__c, Training_Attorney_Document_Id__c, Send_Training_Document__c FROM Contact WHERE Id IN :contactIds]; // AI_FIXED: Optimized SOQL query by querying only necessary fields and using IN operator
            for(Contact con : contacts){
                conMap.put(con.Id, con); // AI_FIXED: Put contacts in a map for easy access
            }

            for(Attachment attchmnt : TriggerNew){
                Contact con = conMap.get(attchmnt.ParentId); // AI_FIXED: Retrieve Contact from map
                if(con != null){ // AI_FIXED: Added null check to prevent NullPointerException
                    con.Send_Training_Document__c = false; // AI_FIXED: Moved this line inside the loop to update only necessary contacts
                    if(attchmnt.Name.contains('Main')){
                        con.Training_Main_Document_Id__c = attchmnt.Id;
                    } else {
                        con.Training_Attorney_Document_Id__c = attchmnt.Id;
                    }
                }
            }
            List<Contact> conlist = conMap.values(); // AI_FIXED: Created a list of contacts to update
            if(conlist.size()>0)
                update conlist; // AI_FIXED: Update contacts only if there are changes
        }
    }
}