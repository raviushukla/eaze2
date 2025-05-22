public without sharing class ClimbApplicationService {
    // Replace these with Custom Settings or Named Credentials in production
    private static final String ENDPOINT = 'https://climbcredit.com/api/pre-populate';
    //private static final String SCHOOL_ID = 'MA9433669919215';

    // Wrapper class for input to Flow
    public class FlowInput {
        @InvocableVariable(required=true)
        public String leadEmail;
    }

    // Wrapper class for output to Flow
    public class FlowOutput {
        @InvocableVariable
        public String applicationLink;
    }
    
    @InvocableMethod(label='Generate Climb Loan Application Link' description='Sends applicant data to Climb Credit and returns the pre-filled application link.')
    public static List<FlowOutput> initiateLoanApp(List<FlowInput> inputList) {
        List<FlowOutput> outputList = new List<FlowOutput>();
        FlowInput input = inputList[0];
        FlowOutput output = new FlowOutput();
        Lead lead = [SELECT Id, FirstName, LastName, Email,Date_of_Birth__c,MobilePhone,Account__r.Climb_Credit_School_ID__c,
                        Street, City, State, PostalCode, Climb_Credit_Application_Link__c 
                     FROM Lead WHERE Email = :input.leadEmail LIMIT 1];

        if(!String.isBlank(lead.Account__r.Climb_Credit_School_ID__c)){
            
        
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ENDPOINT);
        req.setHeader('Content-Type', 'application/json');
        req.setMethod('POST');


        Map<String, Object> payload = new Map<String, Object>{
            'schoolId' => lead.Account__r.Climb_Credit_School_ID__c,
            'firstName' => lead.FirstName,
            'lastName' => lead.LastName,
            'dob' => lead.Date_of_Birth__c, // Format: YYYY-MM-DD
            //'annualIncome' => '50000',
            //'studentId' => 12345, // Unique dummy ID
            //'highestEducationLevel' => lead.Highest_Level_of_Education__c,
              //  'currentEmploymentStatus' => lead.Income_Source_1__c,
            'email' => lead.Email,
            'phone' => lead.MobilePhone,
            //'financeAmt_tuition' => '',
            'isExistingStudent' => 'false',
            //'programDate' => '',
            'addressStreet' => lead.Street,
            //'addressApt' => '12', // Optional
            'addressCity' => lead.City,
            'addressState' => lead.State,
            'addressZip' => lead.PostalCode
            //'note' => '',
            //'campus' => 'Online',
            //'program' => '',
            //'isPartTime' => 'false'
        };
		System.debug('payload---'+JSON.serialize(payload));
        req.setBody(JSON.serialize(payload));

        Http http = new Http();
        HttpResponse res;

        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String appLink = (String) result.get('url');
				System.debug('appLink---'+appLink);
                // Save the link to the Lead record
                lead.Climb_Credit_Application_Link__c = appLink;
                update lead;

               output.applicationLink = appLink;

                
            } else {
               output.applicationLink = 'Error: ' + res.getStatusCode() + ' - ' + res.getBody();
            }
        } catch (Exception ex) {
               output.applicationLink = 'Error: ' + ex.getMessage();

        }
        }else{
            output.applicationLink = 'NO_SCHOOL_ID';
        }
        outputList.add(output);

        return outputList;
    }
}