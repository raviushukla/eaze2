global class PayPossibleHelper {
    
    @future(callout=true)
    public static void sendLeadToPayPossibleFuture( String leadId ){
        sendLeadToPayPossible(leadId);
    }
    
    public static String sendLeadToPayPossible( String leadId  ){
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String apiNames =  '';
        for(string apiName : r.fields.getMap().keySet()){
            if( string.isNotBlank(apiNames)){
                apiNames += ','+apiName;
            }else{
                apiNames = apiName;
            }
        }
        system.debug('leadId'+leadId);
        String queryOnLead = 'Select '+apiNames+' from Lead where id =:leadId';
        system.debug(queryOnLead);
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
            l.ErrorLog__c += '\n'+System.now()+'\n'+ex.getMessage();
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
            
            if(!reqbody.contains('Error:') ){
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
                    returnStr = response.getbody();
                    if(ld.ErrorLog__c != Null){
                        ld.ErrorLog__c += '\n'+System.Now()+'\n '+response.getStatus()+' \n '+response.getStatusCode()+'\n '+response.getbody();
                    }
                    else{
                        ld.ErrorLog__c = System.Now()+'\n'+response.getStatus()+'\n'+response.getStatusCode()+'\n'+response.getbody();
                    }
                    
                }
            }else{
                returnStr = reqBody;
                if( String.isNotBlank(ld.ErrorLog__c ) ){
                    ld.ErrorLog__c += '\n'+System.Now()+'\n '+reqBody;
                }else{
                    ld.ErrorLog__c = System.Now()+'\n'+reqBody;
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
                returnStr = response.getbody();
                if(ld.ErrorLog__c != Null){
                    ld.ErrorLog__c += '\n'+System.Now()+'\n '+response.getStatus()+' \n '+response.getStatusCode()+'\n '+response.getbody();
                }
                else{
                    ld.ErrorLog__c = System.Now()+'\n'+response.getStatus()+'\n'+response.getStatusCode()+'\n'+response.getbody();
                }
                update ld;
            } 
        }else{
            returnStr = 'PP Lead Id or token blank';
        }
        return returnStr;
    }
    
    public static void leadGetfromPayPossibleFuture( String leads, DateTime startTime  ){
        Long timeDiff = ( System.now().getTime() - startTime.getTime()  );
        system.debug('timeDiff='+timeDiff);
        while( timeDiff <= 5000 && !Test.isRunningTest() ){
            timeDiff = ( System.now().getTime() - startTime.getTime() );
            system.debug('timeDiff='+timeDiff);
        }
        Schema.DescribeSObjectResult r = Lead.sObjectType.getDescribe();
        String apiNames =  '';
        for(string apiName : r.fields.getMap().keySet()){
            if( string.isNotBlank(apiNames)){
                apiNames += ','+apiName;
            }else{
                apiNames = apiName;
            }
        }
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
            l.ErrorLog__c += '\n'+System.now()+'\n'+ex.getMessage();
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
                if(ld.ErrorLog__c != Null){
                    ld.ErrorLog__c += '\n'+System.Now()+'\n '+response.getStatus()+' \n '+response.getStatusCode()+'\n '+response.getbody();
                }
                else{
                    ld.ErrorLog__c = System.Now()+'\n'+response.getStatus()+'\n'+response.getStatusCode()+'\n'+response.getbody();
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
        
        if(ld.Loan_Amount__c != null && ld.Loan_Amount__c >= 500 && ld.Loan_Amount__c  <= 100000){
            wrp.amount = integer.valueOf(ld.Loan_Amount__c);
        }else{
            errorLog = 'Loan Amount must be between 500 to 100000.\n';
        }
        
        wrp.purpose = 'large_purchases';
        
        //Merchant Field
        PayPossibleLeadWrapper.merchant merch = new PayPossibleLeadWrapper.merchant();
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
        
        if( String.isNotBlank( ld.Credit_Score_Text__c)){
            wrp.credit_score = ld.Credit_Score_Text__c.toLowerCase();
        }else{
            errorLog += 'Credit Score field is required.\n';
        }
        wrp.agree = true;
        
        //personal mandotary Field
        PayPossibleLeadWrapper.personal per = new PayPossibleLeadWrapper.personal(); 
        if( String.isNotBlank(ld.FirstName) ){  
            per.first_name = ld.FirstName;
        }else{
           errorLog += 'LastName field is required.\n';
        }
        if( String.isNotBlank(ld.lastName)){ 
            per.last_name = ld.lastName;
        }else{
           errorLog += 'LastName field is required.\n';
        }
        if( String.isNotBlank( ld.Social_Security_Number__c ) ){
            per.ssn = ld.Social_Security_Number__c.replace('-','');
        }else{
           errorLog += 'Social_Security_Number field is required.\n';
        }
                                           
        if(ld.Date_of_Birth__c != null){
            per.dob = ld.Date_of_Birth__c;
        }else{
            errorLog += ' Date Of Birth filed is required.\n';
        }
        
        if(ld.Email != null){
            per.email = ld.Email;
            wrp.verify_email = false;
        }else{
            errorLog += 'Email field is required.\n';
        }
        
        if(ld.MobilePhone != Null){
            per.phone = ld.MobilePhone;
        }else{
            errorLog += 'MobilePhone field is required.\n';
        }
        wrp.personal = per;
        
        //Address mandotry Field
        PayPossibleLeadWrapper.address add = new PayPossibleLeadWrapper.address();
        if( String.IsNotBlank( ld.Street ) ){
            add.street1 = ld.Street;
        }else{
            errorLog += 'Street field is required.\n';
        }
        if( String.IsNotBlank( ld.city )){
            add.city = ld.city;
        }else{
            errorLog += 'city field is required.\n';
        }
        if( ld.State != null && ld.State.length() == 2){
            add.state = ld.State;
        }else{
            errorLog += 'State field is required and It must be of only characters.';
        }
        
        if( String.isNotBlank( ld.PostalCode ) && ld.PostalCode.length() <= 5 ){
            add.zip = ld.PostalCode;
        }else{
            errorLog += 'PostalCode field is required and must be of 5 digits.\n';
        }
        
        if( ld.Time_at_Address_In_Months__c != null ){ 
            add.address_length = integer.valueof(ld.Time_at_Address_In_Months__c);
        }else{
             errorLog +=  'Year at Address field is required.\n';
        }
        
        if( String.isNotBlank( ld.Current_Residence_Status__c ) ){
            add.status = ld.Current_Residence_Status__c.toLowerCase();
            add.status = add.status.replace('-','');
        }else{
            errorLog += 'Current Residence Status field is required.\n';
        }
        wrp.address = add;
        
        // Employement Mandotary field
        PayPossibleLeadWrapper.employment emp = new PayPossibleLeadWrapper.employment();
        if( String.isNotBlank( ld.Income_Source_1__c ) ) {
            emp.status = ld.Income_Source_1__c.toLowerCase();
            emp.status = emp.status.replace('-','');
        }else{
            errorLog += 'Income Source 1 filed is required.\n';
        }
        
        if( String.isNotBlank(ld.Position__c )){
            emp.job_title = ld.Position__c;
        }
        if(ld.Hire_Date__c != null){
            emp.hire_date = String.valueOf(ld.Hire_Date__c);
        }
        if( String.isNotBlank(ld.Current_Employer__c)){
            emp.employer_name = ld.Current_Employer__c;
        }
        wrp.employment = emp;
        
        //Income Mandotary field
        PayPossibleLeadWrapper.income incom = new PayPossibleLeadWrapper.income();
        
        if(ld.Annual_Pre_Tax_Income__c != null && ld.Annual_Pre_Tax_Income__c >= 18000){
            incom.annual_income = ld.Annual_Pre_Tax_Income__c;
        }else{
            errorLog += 'Annual pre-tax income field is required and it must be more than 18000.\n';
        }
        if( String.isNotBlank(ld.Payroll_Frequency__c ) ){
            incom.payroll_frequency = ld.Payroll_Frequency__c.toLowerCase();
            incom.payroll_frequency = incom.payroll_frequency.replace('-','');
        }else{
            errorLog += 'Payroll frequency field is required.\n'; 
        }
        if( String.IsNotBlank( ld.Payroll_Type__c ) ){
            incom.payroll_type = ld.Payroll_Type__c.toLowerCase();
            incom.payroll_type = incom.payroll_type.replace('-','');
        }else{
            errorLog += 'Payroll frequency field is required.\n';
        }
        wrp.income = incom;
        
        //PayPossibleLeadWrapper.Mortgage mort = new PayPossibleLeadWrapper.Mortgage();
        //wrp.Mortgage = mort;
        
        PayPossibleLeadWrapper.Bank_account  bnk =  new PayPossibleLeadWrapper.Bank_account();
        wrp.Bank_account = bnk;
        
        String returnStr = '';
        if( String.isNotBlank( errorLog) ){
            returnStr =  'Error: '+errorLog;
        }else{
            returnStr = JSON.serialize(wrp);
        }
        return returnStr;
       
    } 
    
	//this Method ic creating for the response deserilze in our salesforce object...    
    public Static void PayPossibleResponseBody( String ResponseBody, lead ld){
        
        //Deserialize the response data in  this class "PayPossibleOffersWrapper".. 
        PayPossibleLeadWrapper OffersWrap = (PayPossibleLeadWrapper)JSON.deserialize(ResponseBody, PayPossibleLeadWrapper.class);
        
        //Lead Related field 
        ld.Pay_Possible_Status__c = OffersWrap.status;
        if(ld.Pay_Possible_Get_Count__c == null){
            ld.Pay_Possible_Get_Count__c = 0;
        }
        ld.Pay_Possible_Get_Count__c += 1;
        //Offer will return then offer record will be created..
        if(OffersWrap.offers != null && OffersWrap.offers.size() > 0){
            list<Offer__c> listOffer = new list<Offer__c>();
            for(PayPossibleLeadWrapper.offers PPFOFF : OffersWrap.offers){
                Offer__c off = new Offer__c();
                off.Lead__c = ld.id;
                String amount = PPFOFF.amount.replace('$','').replace(',','');
                off.Amount__c = Decimal.valueof(amount);
                off.Apply_url__c = PPFOFF.apply_url;
                String APR = String.valueOF(PPFOFF.apr).replace('%','');
                off.apr__c = Decimal.valueof(APR);
                String monthly_payment = PPFOFF.monthly_payment.replace('$','').replace(',','');
                off.Monthly_Payment__c = Decimal.valueof(monthly_payment);
                off.Term__c = PPFOFF.term;
                off.Offre_Id__c = PPFOFF.id;
                off.Terms__c = PPFOFF.terms;
                off.Date_Created__c = PPFOFF.date_created;
                off.Date_Updated__c = PPFOFF.date_updated;
                off.Name = PPFOFF.originator.name;
                off.Description__c = PPFOFF.originator.description;
                off.Disclaimer__c = PPFOFF.originator.disclaimer;
                off.Image__c = PPFOFF.originator.image;
                off.Email__c = PPFOFF.originator.email;
                off.Phone__c = PPFOFF.originator.phone;
                off.Website__c = PPFOFF.originator.website;
                listOffer.add(off);
            }
            if( listOffer != null && listOffer.size()>0){
                insert listOffer;
            }
        }
        update ld;
    }
	
    global Static String getPayPossibleAccessToken(){
        
        //Wrapper class initialize here for handling the error..
        PaypossibleErrormessages PPEM = new PaypossibleErrormessages();
        
        //Custom Metadata for username,Password,endPointToken,TokenMethod.
        list<Application_Data__mdt> AppMetaData = [select MasterLabel, value__c, DeveloperName from Application_Data__mdt];
        map<String,String> mapCustomMetadata = new map<String,String>();
        for(Application_Data__mdt cust : AppMetaData){
            mapCustomMetadata.put(cust.DeveloperName,cust.value__c);
        }
        
        //Get EndPoint from Metadata....
        String reqEndPoint = mapCustomMetadata.get('PayPossibleTokenEndPoint');
        
        //Get Method from Metadata....
        String reqMethod = mapCustomMetadata.get('PayPossibleTokenMethod');
        
        //Request Type...
        map<String,String> reqHaders = new map<String,String>();
        reqHaders.put('Content-Type', 'application/json');
        reqHaders.put('Accept', 'application/json');
        
        //Get UserName from Metadata....
        String username = mapCustomMetadata.get('PayPossibleUserName');
        
        //Get Password from Metadata....
        String password = mapCustomMetadata.get('PayPossiblePassword');
        

        //Body for the request will send
        String reqBody = '{ "username":"'+username+'","password":"'+password+'"}';
        
        String restoken = '';
        HttpResponse response = new HttpResponse();
        if(Test.isRunningTest() ){
            response.setStatusCode(200);
            response.setBody('{"token":"TEST TPKEN"}');
        }else{
           response = RESTCalloutHelper.makeCallout(reqMethod,reqBody,reqEndPoint,reqHaders);
        }
        if(response.getStatusCode() >= 200 && response.getStatusCode() < 300){
            //wrapper Class use for deserialize the body....
            PayPossibleTokenResponseWrapper wrpClass = (PayPossibleTokenResponseWrapper)JSON.deserialize(response.getBody(), PayPossibleTokenResponseWrapper.class);
            restoken = wrpClass.token;
        }else{
            PPEM.errorMessage = response.getBody();
        }
        return restoken;
    }
    
    //Wrapper Class to handle the error message.
    public class PaypossibleErrormessages{
        public string errorMessage{get;set;}
    }
    
    //wrapper class for deserialize the request return token..  
    global class PayPossibleTokenResponseWrapper{
        String Token {get;set;}
    }
}