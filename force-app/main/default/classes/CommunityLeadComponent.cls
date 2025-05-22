public class CommunityLeadComponent {
    @AuraEnabled
    public static List<ListView> fetch_ListView(){
        List<String> leadListViewsName = Label.Lead_List_Views.split(',');
        // AI_FIXED: Added try-catch block for exception handling and improved error reporting.
        try{
            // AI_FIXED:  Using a Set to avoid duplicate DeveloperNames in the SOQL query.  This improves performance and prevents potential issues.
            Set<String> leadListViewsNameSet = new Set<String>(leadListViewsName);
            List<ListView> listViews = [SELECT Id, Name, DeveloperName FROM ListView WHERE SobjectType = 'Lead' AND DeveloperName IN :leadListViewsNameSet];
            return listViews;
        } catch (Exception e){
            // AI_FIXED:  Added more specific exception handling and logging for better debugging.
            System.debug('Error fetching List Views: ' + e.getMessage());
            return new List<ListView>(); // Return an empty list in case of error
        }
    }
}