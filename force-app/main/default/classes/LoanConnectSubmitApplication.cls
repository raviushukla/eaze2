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
                        FROM Lead WHERE Id =: LeadId];
        Integer creditScore = 0;
        /*
        if( ldObj.Credit_Score__c >= 720 )
        	creditScore = 1;
        else if( ldObj.Credit_Score__c >= 660 && ldObj.Credit_Score__c <= 719)
        	creditScore = 2;
        else if( ldObj.Credit_Score__c >= 600 && ldObj.Credit_Score__c <= 659)
        	creditScore = 3;
        else if( ldObj.Credit_Score__c < 600 ){
        	creditScore = 4;
        	pastBancrupt = 1;
        }*/
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
        
        /*String requestBody = '{ "amount" :'+ ldObj.Loan_Amount__c +
        ', "bankrupt_last7" : 0, "citizen_status" : 1, "city" :"'+ ldObj.City + 
        '","credit_proposal" : 0, "credit_score" : '+ creditScore + 
        ',"dob" :"'+ dateStr + '", "email" : "'+ldObj.Email +
        '", "employment_status" :'+ employmentStatus + 
        ', "firstname" :"'+ ldObj.FirstName +'","housing_status" : '+ housingStatus + 
        ', "income" :'+ ldObj.Monthly_Gross_Income__c + 
        ', "lastname" : "'+ ldObj.LastName +
        '", "monthly_payment" : 10000, "newsletter" : 0,'+
        ' "p_and_c" : '+ pastBancrupt + ',  "pc" : "'+ ldObj.PostalCode +
        '", "phone" : '+ ldObj.Phone +', "province" : "'+ ldObj.State +
        '", "rent_payment" : '+ monthlyRent +', "salutation" : "Mr",  "subscriber" : 0, "terms" : 1,' +
        ' "type" : 4, "ext_consent" : "consentwfs", "address" : "'+ ldObj.Street + 
        '",  "ext_pid" : "ce3f4f04-2dee-4bad-b2d5-b1473218c096" }';*/
                
        String requestBody =  JSON.serialize(lcaObj);
        system.debug( 'request body' + requestBody);
        loanConnectOfferCallOut( requestBody, leadObj );
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
        //insert leadObj; 
        if( response.getStatusCode() == 200){
            LoanWrapper obj = parse(response.getBody());
            leadObj.Loan_Connect_Client_Id__c = obj.client_id;            
            system.debug('Responce - > ' + obj );
            if(  obj != null ){
                if( obj.result != null && obj.result.size() > 0 ){
                    
                    List<Loan_Connect_Offer__c> listOfLCO = new List<Loan_Connect_Offer__c>();
                    for( cls_result lcwObj : obj.result ){
                        system.debug('loan coonnect object' +  lcwObj );
                        Loan_Connect_Offer__c lcoObj = new Loan_Connect_Offer__c();
                        lcoObj.Amount__c = Integer.valueOf( lcwObj.amount);
                        system.debug('ahr value' + lcwObj.apr_range_high);
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
                        lcoObj.Term__c = lcwObj.term != null ? Integer.valueOf( lcwObj.term) : 0;
                        lcoObj.Name = lcoObj.Lender_Name__c + ' - ' + lcoObj.Term__c;
                        lcoObj.Lead__c = leadObj.Id;
                        lcoObj.CurrencyIsoCode = 'CAD';
                        listOfLCO.add(lcoObj);
                    }
                    system.debug('list size' + listOfLCO.size());
                    if( listOfLCO.size() > 0 ){ 
                        offerStatus = 'true';
                        //leadObj.Status = 'Pre-Approved Pending Income Verification';
                        update leadObj;
                        Database.insert(listOfLCO, false);
                        
                    }else{
                        //leadObj.Status = 'Client declined by lender - File Closed';
                        update leadObj;
                    }
                }
            }
        }else {
            Map<String, Object> errorMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            String errorMessg = String.valueOf(errorMap.get('messages') );
            leadObj.ErrorLog__c = leadObj.ErrorLog__c == null ? errorMessg : leadObj.ErrorLog__c + errorMessg;
            offerStatus = leadObj.ErrorLog__c;
            update leadObj;
            
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