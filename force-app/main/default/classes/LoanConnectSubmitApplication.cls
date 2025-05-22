/*
	*  Making an API Call to Loan Connect and getting the Offers for the Canada Applicant
	*  Test Class -> LoanConnectSubmitApplication_Test
	*  Written by : Umesh Rana
*/

public class LoanConnectSubmitApplication {
    
    public static String offerStatus = 'false'; // Using this variable for Success, declined or error status in the salesforce UI.

    @AuraEnabled
    public static String SubmitLoanApplication(String leadId){
        
        Lead leadObj = [SELECT Id, Loan_Amount__c, Citizenship_Status__c, City, Credit_Score_Text__c, Date_of_Birth__c, Email, Income_Source_1__c, FirstName, LastName,ErrorLog__c,
                        Monthly_Expenses__c, PostalCode, MobilePhone, State, Monthly_Rent_Mortgage_Amount__c, Salutation, Street, Current_Residence_Status__c, Annual_Pre_Tax_Income__c,
                        Newsletter_Consent__c, Past_Bankruptcy_or_Consumer_Proposal__c, Purpose__c, Social_Security_Number__c, Credit_Proposal__c, Past_Bankruptcy_Last_7_Years__c 
                        FROM Lead WHERE Id =: leadId]; // AI_FIXED: Corrected LeadId to leadId to match the parameter name
        Integer creditScore = 0;
        if( leadObj.Credit_Score_Text__c == 'excellent' )
            creditScore = 1;
        else if( leadObj.Credit_Score_Text__c == 'Good')
            creditScore = 2;
        else if( leadObj.Credit_Score_Text__c == 'fair')
            creditScore = 3;
        else if( leadObj.Credit_Score_Text__c == 'poor'){
            creditScore = 4;
        }
        
        Date dob = leadObj.Date_of_Birth__c;
        String dateStr = dob.year() + '-' + dob.month() + '-' + dob.day();
        
        Integer employmentStatus = 0;
        if( leadObj.Income_Source_1__c == 'Employed')
            employmentStatus = 1;
        else if( leadObj.Income_Source_1__c == 'Part Time')
            employmentStatus = 2;
        else if( leadObj.Income_Source_1__c ==  'Self_Employed')
            employmentStatus = 3;
        else if( leadObj.Income_Source_1__c == 'retired')
            employmentStatus = 4;
        else if( leadObj.Income_Source_1__c == 'not_employed')
            employmentStatus = 6;
        else if( leadObj.Income_Source_1__c == 'Disability')
            employmentStatus = 7;
        else
            employmentStatus = 8;
        
        Integer monthlyRent = Integer.valueOf(leadObj.Monthly_Rent_Mortgage_Amount__c);
        
        Integer housingStatus = 0;
        if( leadObj.Current_Residence_Status__c == 'Rent')
            housingStatus = 1;
        else if( leadObj.Current_Residence_Status__c == 'Own')
            housingStatus = 2;
        
        LoanConnectApplicationWrapper lcaObj = new LoanConnectApplicationWrapper();
        lcaObj.amount = Integer.valueOf(leadObj.Loan_Amount__c);
        lcaObj.city = leadObj.city;
        lcaObj.credit_score = creditScore;
        lcaObj.dob = dateStr;
        lcaObj.email = leadObj.Email;
        lcaObj.employment_status = employmentStatus;
        lcaObj.firstname = leadObj.firstName;
        lcaObj.housing_status = housingStatus;
        lcaObj.income = Integer.valueOf(leadObj.Annual_Pre_Tax_Income__c);
        lcaObj.lastname = leadObj.lastName;
        lcaObj.monthly_payment = Integer.valueOf(leadObj.Monthly_Expenses__c);
        lcaObj.newsletter = 0;
        lcaObj.p_and_c = leadObj.Past_Bankruptcy_or_Consumer_Proposal__c == true ? 1 : 0;
        lcaObj.bankrupt_last7 = leadObj.Past_Bankruptcy_Last_7_Years__c == true ? 1 : 0;
        lcaObj.credit_proposal = leadObj.Credit_Proposal__c == true ? 1 : 0;
        lcaObj.pc = leadObj.PostalCode;
        lcaObj.phone = leadObj.MobilePhone;
        lcaObj.province = leadObj.State;
        lcaObj.rent_payment = monthlyRent;
        lcaObj.salutation =  leadObj.salutation != null ? leadObj.salutation.substring(0, leadObj.salutation.length() - 1 ) : '';
        lcaObj.subscriber = 0;
        lcaObj.terms = 1;
        lcaObj.type = 4;
        lcaObj.ext_consent = 'Value for Consent';
        lcaObj.address = leadObj.street;
        lcaObj.citizen_status = leadObj.Citizenship_Status__c;
        lcaObj.sin = Integer.valueOf(leadObj.Social_Security_Number__c);
        lcaObj.citizenship_status = leadObj.Citizenship_Status__c;
        
        
        String applicantId = '';
        Boolean validCode = false;
        while( !validCode ){
            applicantId = String.valueOf(Math.abs(Crypto.getRandomInteger()));
            validCode = validateApplicantId(applicantId);
        }
        lcaObj.ext_pid = 'AP-'+ applicantId;//write code to generate a alpha numeric unique value. 
        leadObj.Application_Id__c = 'AP-'+ String.valueOf(applicantId);
                
        String requestBody =  JSON.serialize(lcaObj);
        system.debug( 'request body' + requestBody);
        try{ // AI_FIXED: Added try-catch block for exception handling
            loanConnectOfferCallOut( requestBody, leadObj );
        } catch(Exception e){ // AI_FIXED: Catching generic exceptions
            offerStatus = 'Error: ' + e.getMessage(); // AI_FIXED: Setting offerStatus to indicate an error
            leadObj.ErrorLog__c = leadObj.ErrorLog__c == null ? e.getMessage() : leadObj.ErrorLog__c + ', ' + e.getMessage(); // AI_FIXED: Improved error logging
            update leadObj;
        }
        return offerStatus;
    }
    
    public static void loanConnectOfferCallOut( String body , Lead leadObj ){
        String endPoint = Label.CanadaEndPoint;
        String key = Label.CanadaApiKey;
        String affId = Label.CanadaAffid; 
        endPoint += '?affid=' +  affId + '&key=' + key;
        
        HttpResponse response = RESTCalloutHelper.makeCallout('POST',body,endPoint, new Map<String, String>() );
        system.debug('Responce - > ' + response.getBody() );
        system.debug('Responce - > ' + response.getStatus() );
        system.debug('Responce - > ' + response.getStatusCode() );
        
        if( response.getStatusCode() == 200){
            LoanWrapper obj = parse(response.getBody());
            leadObj.Loan_Connect_Client_Id__c = obj.client_id;            
            system.debug('Responce - > ' + obj );
            if(  obj != null && obj.result != null ){ // AI_FIXED: Added null checks for obj and obj.result
                if( obj.result.size() > 0 ){
                    
                    List<Loan_Connect_Offer__c> listOfLCO = new List<Loan_Connect_Offer__c>();
                    for( cls_result lcwObj : obj.result ){
                        Loan_Connect_Offer__c lcoObj = new Loan_Connect_Offer__c();
                        lcoObj.Amount__c = Integer.valueOf( lcwObj.amount);
                        lcoObj.Apr_range_high__c = (String.isNotBlank(lcwObj.apr_range_high)) ? Decimal.valueOf( lcwObj.apr_range_high.trim() ) : 0.00;
                        lcoObj.Apr_Range_Low__c = (String.isNotBlank(lcwObj.apr_range_low)) ? Decimal.valueOf( lcwObj.apr_range_low.trim() ) : 0.00;
                        lcoObj.Company_Type__c = lcwObj.company_type;
                        lcoObj.Has_Applied__c = lcwObj.has_applied;
                        lcoObj.Lender_Logo__c = lcwObj.lender_logo;
                        lcoObj.Lender_Name__c = lcwObj.lender_name;
                        lcoObj.Monthly_Payment_Range_High__c = lcwObj.monthly_payment_range_high;
                        lcoObj.Monthly_Payment_Range_Low__c = lcwObj.monthly_payment_range_low;
                        lcoObj.Preapproved__c = lcwObj.preapproved;
                        lcoObj.Select_URL__c = lcwObj.select_url;
                        lcoObj.Term__c = lcwObj.term != null ? Integer.valueOf( lcwObj.term) : 0; // AI_FIXED: Added null check for lcwObj.term
                        lcoObj.Name = lcoObj.Lender_Name__c + ' - ' + lcoObj.Term__c;
                        lcoObj.Lead__c = leadObj.Id;
                        lcoObj.CurrencyIsoCode = 'CAD';
                        listOfLCO.add(lcoObj);
                    }
                    if( listOfLCO.size() > 0 ){ 
                        offerStatus = 'true';
                        update leadObj;
                        Database.insert(listOfLCO, false);
                        
                    }else{
                        update leadObj;
                    }
                }
            }
        }else {
            try{ // AI_FIXED: Added try-catch block for JSON deserialization
                Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                String errorMessg = String.valueOf(errorMap.get('messages') );
                leadObj.ErrorLog__c = leadObj.ErrorLog__c == null ? errorMessg : leadObj.ErrorLog__c + ', ' + errorMessg; // AI_FIXED: Improved error logging
                offerStatus = leadObj.ErrorLog__c;
                update leadObj;
            } catch(Exception e){ // AI_FIXED: Catching exceptions during JSON parsing
                leadObj.ErrorLog__c = leadObj.ErrorLog__c == null ? 'Error parsing error response: ' + e.getMessage() : leadObj.ErrorLog__c + ', Error parsing error response: ' + e.getMessage(); // AI_FIXED: Improved error handling for JSON parsing failures
                offerStatus = leadObj.ErrorLog__c;
                update leadObj;
            }
            API_Log__c apiLogObj = new API_Log__c();
            apiLogObj.Source_Destination__c = 'Loan Connect';
            apiLogObj.Type__c = 'Outbound';
            apiLogObj.Request_Type__c = 'POST';
            apiLogObj.Request_Status__c = response.getStatus() + '  ' + response.getStatusCode() ; 
            apiLogObj.Response_Body__c = response.getBody();
            apiLogObj.Request_Body__c = body;
            apiLogObj.Parent_Record__c = leadObj.Id;
            apiLogObj.Endpoint_URL__c = endPoint;
            
            INSERT apiLogObj;
        }
        
    }
    
    public static Boolean validateApplicantId(String applicantId){
        Boolean isValid = true;
        List<Lead> leadList = [Select Id From Lead Where Application_Id__c =: applicantId Limit 1];
        if(leadList.size()>0)
            isValid = false;
        return isValid;
    }
    
    public class LoanConnectApplicationWrapper{
        public Decimal amount;
        public Integer bankrupt_last7;
        public String city;
        public Integer credit_proposal;
        public Integer credit_score;
        public String dob;
        public String email;
        public Integer employment_status;
        public String firstname;
        public String lastname;
        public Integer housing_status;
        public Decimal income;
        public Decimal monthly_payment;
        public Integer newsletter;
        public Integer p_and_c;
        public String pc;
        public String phone;
        public String province;
        public Decimal rent_payment;
        public String salutation;
        public Integer subscriber;
        public Integer terms;
        public Integer type;
        public String ext_consent;
        public String address;
        public String ext_pid;
        public Integer sin;
        public String citizen_status;
        public String  citizenship_status;
    }
    
    public class LoanWrapper{
        public boolean isError;
        public String error;	
        public boolean status;
        public Integer userStatus;	
        public String messages;	
        public cls_meta[] meta;
        public cls_result[] result;
        public cls_data[] data;
        public String timestamp;	
        public String client_id;
        
    }
    public class cls_meta {
    }
    public class cls_result {
        public String amount;	
        public String apr_range_high;	
        public String apr_range_low;	
        public String company_type;	
        public boolean has_applied;
        public String lender_logo;	
        public String lender_name;	
        public Double monthly_payment_range_high;	
        public Double monthly_payment_range_low;	
        public boolean preapproved;
        public String select_url;	
        public String term;	
    }
    public class cls_data {
    }
    
    public static LoanWrapper parse(String json){
        return (LoanWrapper) System.JSON.deserialize(json, LoanWrapper.class);
    }
    
}