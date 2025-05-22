@RestResource(urlMapping = '/agentSignUp/*')
global class AgentSignUpWebService {
    @httpPost
    global static ResponseWrapper createAgent(){
        ResponseWrapper resW = new ResponseWrapper();
        try{
            RestRequest req = RestContext.request;
            // AI_FIXED: Using req.requestBody instead of JSON.serialize(req.params) for better handling of request body.
            String reqBody = req.requestBody.toString();
            System.debug(reqBody);
            RequestWrapper reqW = (RequestWrapper)JSON.deserialize(reqBody, RequestWrapper.class);
            if( String.isNotBlank(reqW.clientCode) && 
               String.isNotBlank(reqW.fName) &&
               String.isNotBlank(reqW.lName) &&
               String.isNotBlank(reqW.email) &&
               String.isNotBlank(reqW.phone)          
              ){
                  // AI_FIXED: Using bind variables to prevent SOQL injection vulnerabilities.
                  list<Account> clientList = [Select Id, Client_Code__c, Application_Link__c, Name, Approved_GA__c from Account where Client_Code__c = :reqW.clientCode limit 1];
                  if( !clientList.isEmpty() ){
                      Account client = clientList[0];
                      Contact newAgent = new Contact();
                      newAgent.AccountId = client.Id;
                      newAgent.FirstName = reqW.fName;
                      newAgent.LastName = reqW.lName;
                      newAgent.Email = reqW.email;
                      newAgent.Phone = reqW.phone;
                      newAgent.Agent_Signup__c = true;
                      resW.gaApproved = clientList[0].Approved_GA__c == 'Yes' ? true : false;
                      // AI_FIXED: Removed commented-out code for generating and validating agent code.  This functionality should be implemented separately if needed.
                      insert newAgent;
                      resW.isSuccess = true;
                      // AI_FIXED: Using bind variables to prevent SOQL injection vulnerabilities.
                      Contact conObj = [Select Agent_Application_Link_New__c, Agent_s_GA_Application_Link__c From Contact Where Id = :newAgent.Id Limit 1];
                      resW.successMessage = conObj.Agent_Application_Link_New__c;
                      resW.gaLink = conObj.Agent_s_GA_Application_Link__c;
                      
                  }else{
                      resW.isSuccess = false;
                      resW.errorMessage = 'Client Code is not valid.';
                  }
              }else{
                  resW.isSuccess = false;
                  resW.errorMessage = 'Required info not filled';
              }
        }catch( Exception ex ){
            // AI_FIXED: Improved error message for better debugging.
            resW.isSuccess = false;
            resW.errorMessage = 'An unexpected error occurred: ' + ex.getMessage();
        }
        return resW;
    }
    
    global class ResponseWrapper{
        Boolean isSuccess;
        String errorMessage;
        String successMessage;
        String gaLink;
        Boolean gaApproved;
        ResponseWrapper(){}
    }
    global class RequestWrapper{
        String fName;
        String lName;
        String email;
        String phone;
        String clientCode;
    }    
}