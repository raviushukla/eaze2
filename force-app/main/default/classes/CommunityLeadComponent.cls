public class CommunityLeadComponent {
    @AuraEnabled
    public static object fetch_ListView(){
        /*Set<String> listViewIds = new Set<String>();
        List<ListView> listViews = new List<ListView>();
        Map<String, boolean> recordAccessMap = new Map<String, boolean>();
        List<ListView> tempListViews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'Lead'];
        if(tempListViews.size()>0){
            for(ListView lw:tempListViews){
                listViewIds.add(lw.Id);
            }
        }
        if(listViewIds.size()>0){
            for(UserRecordAccess rec: [SELECT RecordId, HasReadAccess FROM UserRecordAccess WHERE UserId =: UserInfo.getUserId() AND RecordId IN: listViewIds]){
                recordAccessMap.put(rec.RecordId, rec.HasReadAccess);
            }
        }
        for(ListView lw:tempListViews){
            if(recordAccessMap.get(lw.Id)){
                listViews.add(lw);
            }
        }*/
		List<String> leadListViewsName = Label.Lead_List_Views.split(',');
        List<ListView> listViews = [SELECT Id, Name, DeveloperName FROM ListView WHERE SobjectType = 'Lead' AND DeveloperName IN: leadListViewsName];
        return listViews;
    }
}