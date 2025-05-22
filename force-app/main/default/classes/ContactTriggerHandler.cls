public class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> triggerNew){
        for(Contact con: triggerNew){
            String newAgentCode;
            Boolean validCode = false;
            while( !validCode ){
                newAgentCode = ApexCommonHelper.generateCode(10);
                validCode = ApexCommonHelper.validateNewAgentCode( newAgentCode );
            }
            newAgentCode = newAgentCode.toUpperCase();
            con.Agent_Code__c = newAgentCode;
        }
    }
    
    public static void updateSecondaryEmailOnLead(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap){
        Map<String, Contact> conEmailMap = new Map<String, Contact>();
        for(Contact con: triggerNew){
            if(con.Secondary_Agent_Email__c != triggerOldMap.get(con.Id).Secondary_Agent_Email__c || con.Tertiary_Agent_Email__c != triggerOldMap.get(con.Id).Tertiary_Agent_Email__c){
                conEmailMap.put(con.Id, con);
            }
        }
        if(conEmailMap.size()>0){
            List<Lead> leadList = [Select Secondary_Agent_Email__c, Agent_Name__c From Lead Where Agent_Name__c IN: conEmailMap.KeySet()];
            if(leadList.size()>0){
                for(Lead ld: leadList){
                    ld.Secondary_Agent_Email__c = conEmailMap.get(ld.Agent_Name__c).Secondary_Agent_Email__c;
                    ld.Tertiary_Agent_Email__c = conEmailMap.get(ld.Agent_Name__c).Tertiary_Agent_Email__c;
                }
            }
            update leadList;
        }
    }
}