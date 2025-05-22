@RestResource(urlMapping='/meetingscheduledupdate/*')
global without sharing class GetAppointmentUpdates {
    @HttpPost
    global static void doPost() {
        String creationtime;
        String reqBody = RestContext.request.requestBody.toString();
        system.debug('reqBody='+reqBody);
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(reqBody);
        String requestType = String.valueOf(responseMap.get('type'));
        Map<String, Object> dataMap = (Map<String, Object>) (responseMap.get('data'));
        String creation_time =  String.valueOf(dataMap.get('creation_time'));
        String eventName =  String.valueOf(dataMap.get('subject'));// Getting the event name for GA appointments
        creation_time = creation_time.replace('T', ' ').replace('Z', ' ');
        String starting_time = String.valueOf(dataMap.get('starting_time'));
        starting_time = starting_time.replace('T', ' ').replace('Z', ' ');
        Map<String, Object> formSubmissionMap = (Map<String, Object>) (dataMap.get('form_submission'));
        String name = String.valueOf(formSubmissionMap.get('name'));
        String email = String.valueOf(formSubmissionMap.get('email'));
        String phone = String.valueOf(formSubmissionMap.get('phone'));
        
        String timeZone = String.valueOf(dataMap.get('customer_timezone'));
        timeZone = (timeZone == null ? '' : timeZone);
        getLead(name, email, phone, requestType, creation_time, starting_time, timeZone, eventName);       
    }
    
    global static void getLead(String leadName, String leadEmail, String leadPhone, String requestType, String creationTime, String startingTime, String timeZone, String eventName){
        List<Lead> leadToUpdate = new List<Lead>();
        List<Lead> relatedLead = [SELECT Id, FirstName, lastName, Email, Status, IsConverted, GA_Lead__c, Agent_Name__r.Id , Agent_Name__r.Email, Agent_Name__r.Agent_Code__c FROM Lead 
                                  WHERE ( Email != null AND Email =: leadEmail) OR (MobilePhone != null AND MobilePhone =: leadPhone) OR (Phone != null AND Phone =: leadPhone) ORDER by LastModifiedDate DESC LIMIT 1]; 
        if(relatedLead.size() > 0){
            for(Lead l : relatedLead){
                if(!l.IsConverted && requestType == 'booking.scheduled'){
                    l.Status = Label.LeadStatusValue;
                    List<String> agentCodeList = System.Label.RegularBookingLinkAgentList.split(',');
                    if(l.GA_Lead__c){
                       l.Status = Label.Lead_Status_GA_Booked;
                    }
                    l.Is_Meeting_Scheduled__c = true;
                    l.Meeting_Created__c = dateTime.valueOf(creationTime);
                    l.Meeting_Scheduled__c = dateTime.valueOf(startingTime);
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
                    l.Meeting_Created__c = dateTime.valueOf(creationTime);
                    l.Meeting_Scheduled__c = dateTime.valueOf(startingTime);
                    l.Meeting_Scheduled_Text__c = getClientTime(startingTime, timeZone );                   	
                    leadToUpdate.add(l);
                }
            }
        }
        if(leadToUpdate.size() > 0){
            UPDATE leadToUpdate;
        }
    }
    global static string getClientTime(string dtStr, string clientTz){
        string tzStr = clientTz;
        if(clientTz != null && clientTz.length()==8){
            clientTz = clientTz.replace('+', '+0').replace('-', '-0');
        }
        Schema.DescribeFieldResult fieldResult = User.TimeZoneSidKey.getdescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        {
            if(p.getlabel().contains(clientTz)){
                tzStr = p.getValue();
            }
        }
        system.debug('tzStr '+tzStr);
        dateTime dt = dateTime.valueOf(dtStr);
        date d = dt.date();
        time t = dt.time();
        dateTime dtGMT = DateTime.newInstanceGMT(d, t);
        return dtGMT.format('MM/dd/yyyy hh:mm a',tzStr);
    }
}