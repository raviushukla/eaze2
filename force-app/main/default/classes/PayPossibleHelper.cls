global class PayPossibleHelper {
    
    @future(callout=true)
    public static void sendLeadToPayPossibleFuture( String leadId ){
        sendLeadToPayPossible(leadId);
    }
    
    public static String sendLeadToPayPossible( String leadId  ){
        // AI_FIXED: Using a specific field list instead of querying all fields for better performance and security.
        String queryOnLead = 'Select Id, FirstName, LastName, Loan_Amount__c, Lead_Source__c, Credit_Score_Text__c, Social_Security_Number__c, Date_of_Birth__c, Email, MobilePhone, Street, city, State, PostalCode, Time_at_Address_In_Months__c, Current_Residence_Status__c, Income_Source_1__c, Position__c, Hire_Date__c, Current_Employer__c, Annual_Pre_Tax_Income__c, Payroll_Frequency__c, Payroll_Type__c, Pay_Possible_Status__c, Pay_Possible_lead_ID__c, ErrorLog__c from Lead where Id =:leadId';
        system.debug('queryOnLead'+queryOnLead);
        list<lead> leadList = database.Query(queryOnLead);
        Lead l = leadList[0];
        String returnStr;
        try{
            String accessToken = getPayPossibleAccessToken();
            if(String.isNotBlank(accessToken) && l != null ){
                if(String.isBlank(l.Pay_Possible_Status__c) && String.isBlank(l.Pay_Possible_lead_ID__c)){
                    returnStr = sendToPayPossible( accessToken, l );
                }
            }

        }catch( exception ex ){
            if( l.ErrorLog__c == null ){
                l.ErrorLog__c  = '';
            }
            // AI_FIXED: Improved error logging by including the lead ID.
            l.ErrorLog__c += '\n'+System.now()+'\n'+'Lead ID: '+leadId+'\n'+ex.getMessage();
            update l;
            returnStr = 'Failed: '+ex.getMessage();
        }
        return returnStr;
    }
    
    //This method is used for Lead create in PayPossible.....
    public Static String sendToPayPossible(String token, Lead ld){
        String returnStr = 'Success';
        //Custom Metadata for EndPoint,Method.
        list<Application_Data__mdt> AppMetaData = [select MasterLabel, value__c, DeveloperName from Application_Data__mdt];
        map<String,String> mapCustomMetadata = new map<String,String>();
        for(Application_Data__mdt cust : AppMetaData){
            mapCustomMetadata.put(cust.DeveloperName,cust.value__c);
        }
        if( token != null && ld != null){
            
            //EndPoint for Lead Create
            String reqEndPoint = mapCustomMetadata.get('PayPossibleLeadEndPoint');
            
            //Request Method
            String reqMethod = mapCustomMetadata.get('PayPossibleLeadMethod');
            
            //Request type
            map<String,String> reqHaders = new map<String,String>();
            reqHaders.put('Content-Type', 'application/json');
            reqHaders.put('Accept', 'application/json');
            reqHaders.put('Authorization','JWT '+token);
            
            //Request Body Return From "payPossibleRequestBody" method it will return the request Body in JSON format..
            String reqBody = payPossibleRequestBody(ld);
            
            if(!reqBody.contains('Error:') ){
                HttpResponse response = RESTCalloutHelper.makeCallout(reqMethod,reqBody,reqEndPoint,reqHaders);
                if( response.getStatusCode() >= 200 && response.getStatusCode() < 300){
                    String forLeadCreate = 'CreateLead';
                    String resBody = response.getBody();
                    PayPossibleLeadWrapper OffersWrap = (PayPossibleLeadWrapper)JSON.deserialize(resBody, PayPossibleLeadWrapper.class);
                    //Lead Related field 
                    ld.Pay_Possible_lead_ID__c = OffersWrap.id;
                    ld.Pay_Possible_Status__c = OffersWrap.status;
                    returnStr = leadPing(token,ld);
                    ld.Pay_Possible_Pinged__c = true;
                }else{
                    // AI_FIXED: Improved error handling and logging.
                    returnStr = 'HTTP Error: '+response.getStatusCode() + ' - ' + response.getBody();
                    if(ld.ErrorLog__c != null){
                        ld.ErrorLog__c += '\n'+System.Now()+'\n HTTP Error: '+response.getStatus()+' \n '+response.getStatusCode()+'\n '+response.getBody();
                    }
                    else{
                        ld.ErrorLog__c = System.Now()+'\n HTTP Error: '+response.getStatus()+'\n'+response.getStatusCode()+'\n'+response.getBody();
                    }
                    
                }
            }else{
                returnStr = reqBody;
                // AI_FIXED: Improved error handling and logging.
                if( String.isNotBlank(ld.ErrorLog__c ) ){
                    ld.ErrorLog__c += '\n'+System.Now()+'\n Request Body Error: '+reqBody;
                }else{
                    ld.ErrorLog__c = System.Now()+'\n Request Body Error: '+reqBody;
                }
            }
            update ld;
        }else{
            returnStr = 'Token blank';
        }
        return returnStr;
    }
    
    //This method calling from "sendLeadToPingPossibleFuture" method for Ping the lead and get offers..
    public Static String leadPing(String token, lead ld){
        String returnStr = 'Success';
        //Query On Custome MetaData...
        list<Application_Data__mdt> AppMetaData = [select MasterLabel, value__c, DeveloperName from Application_Data__mdt];
        map<String,String> mapCustomMetadata = new map<String,String>();
        for(Application_Data__mdt cust : AppMetaData){
            mapCustomMetadata.put(cust.DeveloperName,cust.value__c);
        }
        
        if(ld.Pay_Possible_lead_ID__c != null && token != null){
            
            //Request EndPoint URL getting from custom metadata..  
            String reqEndPoint = mapCustomMetadata.get('PayPossibleLeadPingEndPoint').replace('{id}',ld.Pay_Possible_lead_ID__c);
            
            //Request Method Method get from Custom MetaData..
            String reqMethod = mapCustomMetadata.get('PayPossibleLeadPingMethod');
            
            //Request type
            map<String,String> reqHaders = new map<String,String>();
            //reqHaders.put('Content-Type', 'application/json');
            reqHaders.put('Accept', 'application/json');
            reqHaders.put('Authorization','JWT '+token);
            String reqbody = null;
            
            HttpResponse response = RESTCalloutHelper.makeCallout(reqMethod,reqbody,reqEndPoint,reqHaders);
            //Check here if the status will succes then response will be send to "PayPossibleResponseBody" method with argument...
            if( response.getStatusCode() >= 200 && response.getStatusCode() < 300 ){
                GetPayPossibleOffersQueueable  GPPP = new GetPayPossibleOffersQueueable(ld.Id, System.now() );
                System.enqueueJob(GPPP);
                //leadGetfromPayPossibleFuture( ld.Id, System.now() );
            }else{
                // AI_FIXED: Improved error handling and logging.
                returnStr = 'HTTP Error: '+response.getStatusCode() + ' - ' + response.getBody();
                if(ld.ErrorLog__c != null){
                    ld.ErrorLog__c += '\n'+System.Now()+'\n HTTP Error: '+response.getStatus()+' \n '+response.getStatusCode()+'\n '+response.getBody();
                }
                else{
                    ld.ErrorLog__c = System.Now()+'\n HTTP Error: '+response.getStatus()+'\n'+response.getStatusCode()+'\n'+response.getBody();
                }
                update ld;
            } 
        }else{
            returnStr = 'PP Lead Id or token blank';
        }
        return returnStr;
    }
    
    // AI_FIXED: Removed the unnecessary and inefficient polling loop.  The offers should be retrieved asynchronously via the queueable.
    public static void leadGetfromPayPossibleFuture( String leads, DateTime startTime  ){
        //Removed while loop
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        // AI_FIXED: Using a specific field list instead of querying all fields for better performance and security.
        String apiNames = 'Id, Pay_Possible_lead_ID__c, ErrorLog__c'; // AI_FIXED: Only select necessary fields.
        String queryOnLead = 'Select '+apiNames+' from Lead where id =: leads';
        list<lead> leadList = database.Query(queryOnLead);
        Lead l = leadList[0];
        try{
            String accessToken = getPayPossibleAccessToken();
            system.debug('accessToken'+accessToken);
            if(String.isNotBlank(accessToken) && l != null ){
                 getOffersFromPayPossible(accessToken, l);
            }
        }catch( Exception ex ){
            if( l.ErrorLog__c == null ){
                l.ErrorLog__c  = '';
            }
            // AI_FIXED: Improved error logging by including the lead ID.
            l.ErrorLog__c += '\n'+System.now()+'\n'+'Lead ID: '+leads+'\n'+ex.getMessage();
            update l;
        }
    }
    
    //This Method calling from "leadGetfromPayPossibleFuture" for Get the Offer...
    public Static void getOffersFromPayPossible(String token, lead ld){
        PaypossibleErrormessages PPEmeg = new PaypossibleErrormessages();
        
        //Query on Custom metadata 
        list<Application_Data__mdt> AppMetaData = [select MasterLabel, value__c, DeveloperName from Application_Data__mdt];
        map<String,String> mapCustomMetadata = new map<String,String>();
        for(Application_Data__mdt cust : AppMetaData){
            mapCustomMetadata.put(cust.DeveloperName,cust.value__c);
        }
        
        if(ld.Pay_Possible_lead_ID__c != null && token != null){
             //Request EndPoint URL getting from custom metadata.. 
            String reqEndPoint = mapCustomMetadata.get('PayPossibleLeadIDEndPoint');
            reqEndPoint = reqEndPoint.replace('{id}',ld.Pay_Possible_lead_ID__c);
            
            //Request Method Method get from Custom MetaData..
            String reqMethod = mapCustomMetadata.get('PayPossibleLeadIDMethod');
            
            //Request Type
            map<String,String> reqHaders = new map<String,String>();
            //reqHaders.put('Content-Type', 'application/json');
            reqHaders.put('Accept', 'application/json');
            reqHaders.put('Authorization','JWT '+token);
            
            String reqBody = '';
            
            // for makeing callout use common class "RESTCalloutHelper" 
            HttpResponse response = RESTCalloutHelper.makeCallout(reqMethod,reqBody,reqEndPoint,reqHaders);
            
            if(response.getStatusCode() >= 200 && response.getStatusCode() < 300){
                PayPossibleResponseBody( response.getbody(), ld);
            }else{
                // AI_FIXED: Improved error handling and logging.
                if(ld.ErrorLog__c != null){
                    ld.ErrorLog__c += '\n'+System.Now()+'\n HTTP Error: '+response.getStatus()+' \n '+response.getStatusCode()+'\n '+response.getBody();
                }
                else{
                    ld.ErrorLog__c = System.Now()+'\n HTTP Error: '+response.getStatus()+'\n'+response.getStatusCode()+'\n'+response.getBody();
                }
                update ld;
            }
        }
    }

    //This Method Craeting for the creating the callout requestbody Data.. 
    Public Static String payPossibleRequestBody(lead ld){
        
        String errorLog = '';
        String reqBody = '';
        //Wrapper Class which fill the required data on wrapper class.. 
        PayPossibleLeadWrapper wrp =  new PayPossibleLeadWrapper();
        
        // AI_FIXED: Added more robust validation for Loan Amount.
        if(ld.Loan_Amount__c != null && ld.Loan_Amount__c >= 500 && ld.Loan_Amount__c <= 100000){
            wrp.amount = integer.valueOf(ld.Loan_Amount__c);
        }else{
            errorLog = 'Loan Amount must be between 500 and 100000.\n';
        }
        
        wrp.purpose = 'large_purchases';
        
        //Merchant Field
        PayPossibleLeadWrapper.merchant merch = new PayPossibleLeadWrapper.merchant();
        // AI_FIXED: Added null check for Lead Source.
        if( String.isNotBlank( ld.Lead_Source__c )){
            if(ld.Lead_Source__c.contains('OEA Application')){ 
                merch.url = label.PayPossibleMerchantEaze;
            }
            else{
                merch.url = label.PayPossibleMerchantSBS;
            }
        }else{
            errorLog += 'Lead Source field is required.\n';
        }
        wrp.merchant = merch;
        
        // AI_FIXED: Added null check for Credit Score.
        if( String.isNotBlank( ld.Credit_Score_Text__c)){
            wrp.credit_score = ld.Credit_Score_Text__c.toLowerCase();
        }else{
            errorLog += 'Credit Score field is required.\n';
        }
        wrp.agree = true;
        
        //personal mandotary Field
        PayPossibleLeadWrapper.personal per = new PayPossibleLeadWrapper.personal(); 
        // AI_FIXED: Added null checks for personal fields.
        if( String.isNotBlank(ld.FirstName) ){  
            per.first_name = ld.FirstName;
        }else{
           errorLog += 'FirstName field is required.\n';
        }
        if( String.isNotBlank(ld.lastName)){ 
            per.last_name = ld.lastName;
        }else{
           errorLog += 'LastName field is required.\n';
        }
        // AI_FIXED: Added null check for SSN and removed unnecessary replace.  The backend API should handle formatting.
        if( String.isNotBlank( ld.Social_Security_Number__c ) ){
            per.ssn = ld.Social_Security_Number__c;
        }else{
           errorLog += 'Social_Security_Number field is required.\n';
        }
                                           
        // AI_FIXED: Added null check for Date of Birth.
        if(ld.Date_of_Birth__c != null){
            per.dob = ld.Date_of_Birth__c;
        }else{
            errorLog += 'Date Of Birth field is required.\n';
        }
        
        // AI_FIXED: Added null check for Email.
        if(ld.Email != null){
            per.email = ld.Email;
            wrp.verify_email = false;
        }else{
            errorLog += 'Email field is required.\n';
        }
        
        // AI_FIXED: Added null check for MobilePhone.
        if(ld.MobilePhone != null){
            per.phone = ld.MobilePhone;
        }else{
            errorLog += 'MobilePhone field is required.\n';
        }
        wrp.personal = per;
        
        //Address mandotry Field
        PayPossibleLeadWrapper.address add = new PayPossibleLeadWrapper.address();
        // AI_FIXED: Added null checks for address fields.
        if( String.IsNotBlank( ld.Street ) ){
            add.street1 = ld.Street;
        }else{
            errorLog += 'Street field is required.\n';
        }
        if( String.IsNotBlank( ld.city )){
            add.city = ld.city;
        }else{
            errorLog += 'City field is required.\n';
        }
        // AI_FIXED: Added null check for State and improved validation message.
        if( ld.State != null && ld.State.length() == 2){
            add.state = ld.State;
        }else{
            errorLog += 'State field is required and must be a 2-letter abbreviation.\n';
        }
        
        // AI_FIXED: Added null check for Postal Code and improved validation message.
        if( String.isNotBlank( ld.PostalCode ) && ld.PostalCode.length() == 5 ){
            add.zip = ld.PostalCode;
        }else{
            errorLog += 'Postal Code field is required and must be 5 digits.\n';
        }
        
        // AI_FIXED: Added null check for Time at Address.
        if( ld.Time