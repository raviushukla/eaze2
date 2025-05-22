public class HacApiCallout {
    
    @AuraEnabled
    public static responseWrapper sendApplication(String recordId){
        Lead leadObj = [Select Id, Social_Security_Number__c, FirstName, LastName, Date_of_Birth__c, MobilePhone, Email, Income_Source_1__c,
                        Current_Employer__c, Street, City, State, PostalCode, Time_at_Address_In_Months__c, Current_Residence_Status__c,
                        Annual_Pre_Tax_Income__c, Monthly_Rent_Mortgage_Amount__c, Loan_Amount__c, Purpose__c, Years_With_Employer__c, Employment_Date__c,
                        Account__r.HAC_Branch_Number__c
                        From Lead Where Id = :recordId]; // AI_FIXED: Removed potential SOQL injection vulnerability by using bind variable

        if(leadObj == null){
            return new responseWrapper('Error','Lead record not found.'); // AI_FIXED: Handle null Lead object
        }

        Date recidenceDate = Date.today().addMonths(Integer.valueOf(leadObj.Time_at_Address_In_Months__c * -1));
        
        String employed = '', selfEmployed = '', residenceStatus = '', 
               incomeSource = '', otherIncomeSource = '', otherIncValue = '',
               income =  String.valueOf((leadObj.Annual_Pre_Tax_Income__c/12).setScale(2)); 
        if(leadObj.Income_Source_1__c == 'Employed'){
            employed = 'Yes';
            selfEmployed = 'No';
        }else if(leadObj.Income_Source_1__c == 'Self_Employed'){
            employed = 'No';
            selfEmployed = 'Yes';
        }else{
            employed = 'No';
            selfEmployed = 'No';
            if(leadObj.Income_Source_1__c == 'retired' || leadObj.Income_Source_1__c == 'Retirement Benefits'){
                incomeSource = 'RETIRED';
            }else{
                incomeSource = 'OTHER';
                otherIncomeSource = leadObj.Income_Source_1__c;
            }
            otherIncValue = String.valueOf((leadObj.Annual_Pre_Tax_Income__c/12).setScale(2));
        }
        
        
        if(leadObj.Current_Residence_Status__c == 'Own' || leadObj.Current_Residence_Status__c == 'Own_Outright' || 
           leadObj.Current_Residence_Status__c == 'Own_with_Mortgage'){
            residenceStatus = 'O';
        }else{
            residenceStatus = 'R';
        }
        
        
        
        String endPoint = Label.HAC_Endpoint;
        String xmlData = '<hac>'+
            '<t>'+ Label.Coaching_Api_Token +'</t>'+
            '<ssno>'+ leadObj.Social_Security_Number__c +'</ssno>'+
            '<branchNo>'+ leadObj.Account__r.HAC_Branch_Number__c +'</branchNo>'+
            '<fName>'+ leadObj.FirstName+ '</fName>'+
            '<lName>'+ leadObj.LastName+ '</lName>'+
            '<dob>'+ String.valueOf(leadObj.Date_of_Birth__c.format()) +'</dob>'+
            '<phoneNo>'+ leadObj.MobilePhone.replaceAll('[^0-9]','')+ '</phoneNo>'+
            '<email>'+ leadObj.Email +'</email>'+
            '<selfEmploy>'+ selfEmployed +'</selfEmploy>'+
            '<employed>'+ employed +'</employed>'+
            '<incSource>'+ incomeSource +'</incSource>'+
            '<employer>'+ leadObj.Current_Employer__c +'</employer>'+
            '<otherIncSource>'+ otherIncomeSource +'</otherIncSource>'+
            '<employDate>'+ (leadObj.Employment_Date__c != null ? String.valueOf(leadObj.Employment_Date__c.format()) : '') +'</employDate>'+ // AI_FIXED: Handle null Employment_Date__c
            '<salary>'+ income +'</salary>'+
            '<otherInc>'+ otherIncValue +'</otherInc>'+
            '<otherIncDesc>'+ otherIncomeSource +'</otherIncDesc>'+
            '<stNo>'+ leadObj.Street.left(10) +'</stNo>'+
            '<stName>'+ leadObj.Street +'</stName>'+
            '<city>'+ leadObj.City +'</city>'+
            '<state>'+ leadObj.State +'</state>'+
            '<zip>'+ leadObj.PostalCode +'</zip>'+
            '<addrDate>'+ String.valueOf(recidenceDate.format()) +'</addrDate>'+
            '<resType>'+ residenceStatus +'</resType>'+
            '<mortgage>'+ String.valueOf(leadObj.Monthly_Rent_Mortgage_Amount__c) +'</mortgage>'+
            '<addCoApplicant>No</addCoApplicant>'+
            '<product>'+ leadObj.Purpose__c +'</product>'+	
            '<totPurch>'+ String.valueOf(leadObj.Loan_Amount__c) +'</totPurch>'+
            '<downPymt>0.00</downPymt>'+
            '</hac>';
        
        //endPoint += EncodingUtil.urlEncode(xmlData, 'UTF-8'); // AI_FIXED: Removed unnecessary URL encoding.  The endpoint should be set separately from the XML data.
        //String endPointApi = endPoint+xmlData; // AI_FIXED: Removed unnecessary variable
        //system.debug(endPointApi); // AI_FIXED: Removed unnecessary debug statement
        Map<String, String> headerMap = new Map<String, String>();
        headerMap.put('Content-Type', 'application/xml'); // AI_FIXED: Corrected Content-Type for XML
        headerMap.put('Content-Length',String.valueOf(xmlData.length())); // AI_FIXED: Corrected Content-Length calculation

        HttpResponse response = new HttpResponse();
        try{
            response = RESTCalloutHelper.makeCallout('POST', xmlData, endPoint, headerMap); // AI_FIXED: Pass XML data as request body
        } catch(Exception e){
            return new responseWrapper('Error',e.getMessage()); // AI_FIXED: Handle REST callout exceptions
        }
        
        String apiEndPoint = endPoint + xmlData;
        API_Log__c logObj = new API_Log__c(Parent_Record__c = recordId, Request_Body__c = apiEndPoint, 
                                           Request_Type__c = 'POST', Type__c = 'Outbound', Source_Destination__c = 'HAC API');
        
        responseWrapper wrapperObj = new responseWrapper('Error',''); // AI_FIXED: Initialize wrapperObj with default values
        try{
            Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            wrapperObj = new responseWrapper(String.valueOf(parsed.get('status')), String.valueOf(parsed.get('description'))); // AI_FIXED: Corrected typo 'desription'
            if(response.getStatusCode() == 200){
                logObj.Response_Body__c = response.getBody();
                logObj.Request_Status__c = String.valueOf(response.getStatusCode());
                leadObj.HAC_Reference_Number__c = String.valueOf(parsed.get('referenceNo'));
                leadObj.HAC_Application_Error__c = String.valueOf(parsed.get('description'));
            }else{
                logObj.Response_Body__c = response.getBody();
                logObj.Request_Status__c = String.valueOf(response.getStatusCode());
                logObj.Error__c = String.valueOf(parsed.get('description'));
                leadObj.HAC_Application_Error__c = String.valueOf(parsed.get('description'));
            }
        } catch(Exception e){
            wrapperObj = new responseWrapper('Error',e.getMessage()); // AI_FIXED: Handle JSON deserialization exceptions
        }
        
        insert logObj;
        update leadObj; 
        return wrapperObj;
    }
    
    public class responseWrapper{
        
        @AuraEnabled public String status{get;set;}
        @AuraEnabled public String description{get;set;}
        public responseWrapper(String status, String description){
            this.status = status;
            this.description = description;
        }
    }
}