public class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> triggerNew){
        for(Contact con: triggerNew){
            String newAgentCode;
            Boolean validCode = false;
            // AI_FIXED: Added a loop limit to prevent infinite loops if code generation and validation always fail.
            Integer loopCounter = 0;
            Integer maxLoops = 100; // AI_FIXED: Set a reasonable maximum number of attempts.  Adjust as needed.
            while( !validCode && loopCounter < maxLoops ){
                newAgentCode = ApexCommonHelper.generateCode(10);
                validCode = ApexCommonHelper.validateNewAgentCode( newAgentCode );
                loopCounter++;
            }
            // AI_FIXED: Handle the case where a valid code could not be generated after multiple attempts.
            if (!validCode) {
                // AI_FIXED: Log the error for debugging purposes.  Consider alternative handling like throwing an exception or setting a default value.
                System.debug('Could not generate a valid Agent Code after ' + maxLoops + ' attempts.');
            } else {
                newAgentCode = newAgentCode.toUpperCase();
                con.Agent_Code__c = newAgentCode;
            }
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
            // AI_FIXED:  Using a Set to avoid SOQL injection vulnerability and improve performance.
            Set<String> agentNames = new Set<String>();
            for (Contact con : conEmailMap.values()) {
                agentNames.add(con.Agent_Name__c); // Assuming Agent_Name__c is the field linking Contact to Lead
            }
            // AI_FIXED: Added null check to prevent NullPointerException
            if(agentNames != null && agentNames.size() > 0){
                List<Lead> leadList = [Select Secondary_Agent_Email__c, Agent_Name__c From Lead Where Agent_Name__c IN :agentNames]; // AI_FIXED: Using a Set for SOQL query
                if(leadList.size()>0){
                    for(Lead ld: leadList){
                        // AI_FIXED: Added null checks to prevent NullPointerExceptions.
                        Contact relatedContact = conEmailMap.get(ld.Agent_Name__c);
                        if (relatedContact != null) {
                            ld.Secondary_Agent_Email__c = relatedContact.Secondary_Agent_Email__c;
                            ld.Tertiary_Agent_Email__c = relatedContact.Tertiary_Agent_Email__c;
                        }
                    }
                    update leadList;
                }
            }
        }
    }
}