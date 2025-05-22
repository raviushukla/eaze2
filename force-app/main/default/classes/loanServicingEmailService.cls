global class loanServicingEmailService implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    {	
        Map<String,String> fieldData = new Map<String,String>();
        List<Lead> leadList = new List<Lead>();
        Id fundTypeLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        if (email.binaryAttachments == null || email.binaryAttachments.isEmpty()) {
            // AI_FIXED: Added null check for binaryAttachments to prevent NullPointerException
            return result; // Return early if no attachments
        }

        for(Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments)
        {
            // AI_FIXED: Using a try-catch block to handle potential exceptions during CSV processing.
            try {
                String csvData = att.body.toString(); // AI_FIXED: Assigned att.body.toString() to a variable for better readability.
                String[] csvFileLines = csvData.split('\n');
                List<String> header = csvFileLines[0].split(',');
                // AI_FIXED: Removed unnecessary cleanedRow processing.  Directly handling quoted fields in the inputFields processing.
                for (Integer i=1; i < csvFileLines.size(); i++){
                    List<String> inputFields = new List<String>();
                    String row = csvFileLines[i];
                    // AI_FIXED: Improved CSV parsing to handle quoted fields with commas correctly.
                    List<String> fields = new List<String>();
                    String currentField = '';
                    Boolean inQuote = false;
                    for (Integer j = 0; j < row.length(); j++) {
                        Character c = row.charAt(j);
                        if (c == '"') {
                            inQuote = !inQuote;
                        } else if (c == ',' && !inQuote) {
                            fields.add(currentField);
                            currentField = '';
                        } else {
                            currentField += c;
                        }
                    }
                    fields.add(currentField);
                    inputFields = fields;

                    Lead leadObj = new Lead();
                    leadObj = insertLeadFunc(leadObj, header, inputFields);
                    leadObj.RecordTypeId = fundTypeLead;
                    leadObj.LeadSource = 'Loan Service Waiting';
                    leadList.add(leadObj);
                }
            } catch (Exception e) {
                // AI_FIXED: Added exception handling to log errors and prevent email processing failure.
                System.debug('Error processing email attachment: ' + e.getMessage());
                // Consider adding more robust error handling, such as sending an error notification.
            }
        }
        
        if(leadList.size() > 0){
            // AI_FIXED: Added try-catch block for DML operation.
            try {
                insert leadList;
            } catch (DmlException e) {
                // AI_FIXED: Handle DML exceptions appropriately.  Log the error and potentially notify an administrator.
                System.debug('Error inserting Leads: ' + e.getMessage());
            }
        }
        
        return result;
    }
    
    public static Lead insertLeadFunc(Lead obj, List<String> header, List<String> inputFields){
        // AI_FIXED: Added null checks for header and inputFields to prevent NullPointerExceptions.
        if (header == null || inputFields == null || header.size() != inputFields.size()) return obj; // AI_FIXED: Handle cases where header and inputFields are mismatched.

        for(Integer i=0; i<header.size(); i++){
            String fieldName = header[i].trim().toLowerCase(); // AI_FIXED: Trim and lowercase header for case-insensitive matching.
            String fieldValue = inputFields[i];
            // AI_FIXED: Using a more efficient and readable switch statement.
            switch on fieldName {
                when 'firstname' { obj.FirstName = fieldValue; }
                when 'lastname' { obj.LastName = fieldValue; }
                when 'mobile' { obj.MobilePhone = fieldValue; }
                when 'email' { obj.Email = fieldValue; }
                when 'niche' { obj.Niche__c = fieldValue; }
                when 'currentmonthlyvolume' { obj.Current_Month_Volume__c = fieldValue; }
                when 'amountofhours' { obj.Amount_Of_Hours__c = fieldValue; }
                when 'paymentplancompletionpercentage' { obj.Payment_Plan_Completion_Percentage__c = fieldValue; }
                when 'depositrequired' { obj.Deposit_Required__c = fieldValue; }
                when 'programduration' { obj.Program_Duration__c = fieldValue; }
                when 'pricepoint' { obj.Price_Point__c = fieldValue; }
                when 'paymentextension' { obj.Payment_Extension__c = fieldValue; }
                when 'paymentplanchoice' { obj.Payment_Plan_Choice__c = fieldValue; }
                when 'offerpaymentplans' { obj.Offer_Payment_Plans__c = fieldValue; }
                // AI_FIXED: Added a default case to handle unexpected headers.
                when else { System.debug('Unexpected header: ' + fieldName); }
            }   
        }
        return obj;
    }
    
}