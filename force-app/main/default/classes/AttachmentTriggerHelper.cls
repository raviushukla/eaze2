public class AttachmentTriggerHelper {
    public static void updateTrainingLinkOnContact(List<Attachment> TriggerNew){
        List<Contact> conlist = new List<Contact>();
        for(Attachment attchmnt : TriggerNew){
            Contact con = new Contact();
            con.Id = attchmnt.ParentId;
            con.Send_Training_Document__c = false;
            if(attchmnt.Name.contains('Main')){
                con.Training_Main_Document_Id__c = attchmnt.Id;
            }
            else{
                con.Training_Attorney_Document_Id__c = attchmnt.Id;
            }
            conlist.add(con);
        }  
        if(conlist.size()>0)
            update conlist;
    }
}