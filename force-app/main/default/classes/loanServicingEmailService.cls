global class loanServicingEmailService implements Messaging.InboundEmailHandler
{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope)
    {	
        Map<String,String> fieldData = new Map<String,String>();
        List<Lead> leadList = new List<Lead>();
        Id fundTypeLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        
        for(Messaging.InboundEmail.BinaryAttachment att : email.binaryAttachments)
        {
            system.debug(att.body.toString());
            String[] csvFileLines = att.body.toString().split('\n');
            List<String> cleanedRow = new List<String>();
            system.debug('**** '+ csvFileLines.size());
            for(String row : csvFileLines){                   
                String connectedFields = '';
                if( row.contains('"') ){
                    for( String field : row.split('"') ){
                        if( !cleanedRow.contains(row) ){
                            if( field.startsWith(',') || field.endsWith(',') ){
                                connectedFields += field;
                            }else{
                                field = field.replace(',','ABCDEFGHI');
                                connectedFields += field;                                
                            }
                        }
                    }
                    cleanedRow.add(connectedFields);
                }else{
                    cleanedRow.add(row);
                } 
            }
            system.debug('**** '+ cleanedRow.size());
            List<String> header = csvFileLines[0].split(',');
            
            if( cleanedRow != null ){
                csvFileLines = cleanedRow;
            }
            
            for (Integer i=1;i<csvFileLines.size();i++){
                List<String> inputFields = new List<String>();
                inputFields = csvFileLines[i].split(',');
                Lead leadObj = new Lead();
                leadObj = insertLeadFunc(leadObj, header, inputFields);
                leadObj.RecordTypeId = fundTypeLead;
                leadObj.LeadSource = 'Loan Service Waiting';
                leadList.add(leadObj);
                
            }  
            
        }
        
        if(leadList.size() > 0){
            insert leadList;
        }
        
        return result;
    }
    
    public static Lead insertLeadFunc(Lead obj, List<String> header, List<String> inputFields){
        for(Integer i=0; i<header.size(); i++){
            switch on header[i]
            {   
                when 'firstName'{ obj.put('FirstName',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'lastName'{ obj.put('LastName',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'mobile'{ obj.put('MobilePhone',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'email'{ obj.put('Email',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'niche'{ obj.put('Niche__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'currentMonthlyVolume'{ obj.put('Current_Month_Volume__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'amountOfHours'{ obj.put('Amount_Of_Hours__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'paymentPlanCompletionPercentage'{ obj.put('Payment_Plan_Completion_Percentage__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'depositRequired'{ obj.put('Deposit_Required__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'programDuration'{ obj.put('Program_Duration__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'pricepoint'{ obj.put('Price_Point__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'paymentExtension'{ obj.put('Payment_Extension__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'paymentPlanChoice'{ obj.put('Payment_Plan_Choice__c',inputFields[i].replace('ABCDEFGHI',','));  }
                when 'offerPaymentPlans'{ obj.put('Offer_Payment_Plans__c',inputFields[i].replace('ABCDEFGHI',','));  }

            }   
            System.debug(header[i] +'-->'+inputFields[i]);
        }
        system.debug('Obj :' + obj);
        return obj;
    }
    
}