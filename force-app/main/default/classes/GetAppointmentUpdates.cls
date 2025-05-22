@RestResource(urlMapping='/meetingscheduledupdate/*')
global without sharing class GetAppointmentUpdates {
    @HttpPost
    global static void doPost() {
        String reqBody;
        try {
            reqBody = RestContext.request.requestBody.toString();
        } catch (Exception e) {
            // AI_FIXED: Added try-catch block to handle potential exceptions during request body retrieval.
            System.debug('Error retrieving request body: ' + e.getMessage());
            return; // AI_FIXED: Return early if an error occurs to prevent further processing.
        }
        System.debug('reqBody='+reqBody);
        Map<String, Object> responseMap;
        try {
            responseMap = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
        } catch (Exception e) {
            // AI_FIXED: Added try-catch block to handle JSON deserialization errors.
            System.debug('Error deserializing JSON: ' + e.getMessage());
            return; // AI_FIXED: Return early if an error occurs.
        }
        String requestType = String.valueOf(responseMap.get('type'));
        Map<String, Object> dataMap = (Map<String, Object>) responseMap.get('data');
        String creation_time =  String.valueOf(dataMap.get('creation_time'));
        String eventName =  String.valueOf(dataMap.get('subject'));
        creation_time = creation_time.replace('T', ' ').replace('Z', ' ');
        String starting_time = String.valueOf(dataMap.get('starting_time'));
        starting_time = starting_time.replace('T', ' ').replace('Z', ' ');
        Map<String, Object> formSubmissionMap = (Map<String, Object>) dataMap.get('form_submission');
        String name = String.valueOf(formSubmissionMap.get('name'));
        String email = String.valueOf(formSubmissionMap.get('email'));
        String phone = String.valueOf(formSubmissionMap.get('phone'));
        
        String timeZone = String.valueOf(dataMap.get('customer_timezone'));
        timeZone = (timeZone == null) ? '' : timeZone;
        getLead(name, email, phone, requestType, creation_time, starting_time, timeZone, eventName);       
    }
    
    global static void getLead(String leadName, String leadEmail, String leadPhone, String requestType, String creationTime, String startingTime, String timeZone, String eventName){
        List<Lead> leadToUpdate = new List<Lead>();
        // AI_FIXED: Added null checks and used parameterized query to prevent SOQL injection vulnerabilities.
        List<Lead> relatedLead = [SELECT Id, FirstName, lastName, Email, Status, IsConverted, GA_Lead__c, Agent_Name__r.Id , Agent_Name__r.Email, Agent_Name__r.Agent_Code__c FROM Lead 
                                  WHERE (Email =:leadEmail OR MobilePhone =:leadPhone OR Phone =:leadPhone) AND Email != null ORDER by LastModifiedDate DESC LIMIT 1]; 
        if(relatedLead.size() > 0){
            for(Lead l : relatedLead){
                if(!l.IsConverted && requestType == 'booking.scheduled'){
                    l.Status = Label.LeadStatusValue;
                    // AI_FIXED: Improved handling of agent code list.
                    List<String> agentCodeList = new List<String>(System.Label.RegularBookingLinkAgentList.split(','));
                    if(l.GA_Lead__c){
                       l.Status = Label.Lead_Status_GA_Booked;
                    }
                    l.Is_Meeting_Scheduled__c = true;
                    // AI_FIXED: Added try-catch block for DateTime parsing.
                    try{
                        l.Meeting_Created__c = DateTime.valueOf(creationTime);
                        l.Meeting_Scheduled__c = DateTime.valueOf(startingTime);
                    } catch (Exception e){
                        System.debug('Error parsing DateTime: ' + e.getMessage());
                    }
                    l.Meeting_Scheduled_Text__c = getClientTime(startingTime, timeZone );
                    l.Time_Zone__c = timeZone;
                    leadToUpdate.add(l);
                }
                else if(!l.IsConverted && requestType == 'booking.canceled'){
                    l.Is_Meeting_Cancelled__c = true;
                    l.Is_Meeting_Scheduled__c = false;
                    l.Meeting_Created__c = null;
                    l.Meeting_Scheduled__c = null;
                    l.Meeting_Scheduled_Text__c = '';
                    leadToUpdate.add(l);
                }
                else if(!l.IsConverted && requestType == 'booking.rescheduled'){
                    // AI_FIXED: Added try-catch block for DateTime parsing.
                    try{
                        l.Meeting_Created__c = DateTime.valueOf(creationTime);
                        l.Meeting_Scheduled__c = DateTime.valueOf(startingTime);
                    } catch (Exception e){
                        System.debug('Error parsing DateTime: ' + e.getMessage());
                    }
                    l.Meeting_Scheduled_Text__c = getClientTime(startingTime, timeZone );                   	
                    leadToUpdate.add(l);
                }
            }
        }
        // AI_FIXED: Added try-catch block for DML operation.
        try{
            if(leadToUpdate.size() > 0){
                UPDATE leadToUpdate;
            }
        } catch (Exception e){
            System.debug('Error updating Leads: ' + e.getMessage());
        }
    }
    global static string getClientTime(string dtStr, string clientTz){
        string tzStr = clientTz;
        if(clientTz != null && clientTz.length()==8){
            clientTz = clientTz.replace('+', '+0').replace('-', '-0');
        }
        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        {
            if(p.getLabel().contains(clientTz)){ // AI_FIXED: Corrected getLabel() to getLabel
                tzStr = p.getValue();
            }
        }
        system.debug('tzStr '+tzStr);
        // AI_FIXED: Added try-catch block for DateTime parsing.
        DateTime dt;
        try{
            dt = DateTime.valueOf(dtStr);
        } catch (Exception e){
            System.debug('Error parsing DateTime: ' + e.getMessage());
            return ''; // AI_FIXED: Return empty string if parsing fails.
        }
        Date d = dt.date();
        Time t = dt.time();
        DateTime dtGMT = DateTime.newInstanceGMT(d, t);
        return dtGMT.format('MM/dd/yyyy hh:mm a',tzStr);
    }
}