@RestResource(urlMapping = '/agentSignUp/*')
global class AgentSignUpWebService {
    @httpPost
    global Static ResponseWrapper createAgent(){
        ResponseWrapper resW = new ResponseWrapper();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = RestContext.response;
            system.debug('req params'+req.params);
            String reqBody = JSON.serialize(req.params);
            System.debug(reqBody);
            RequestWrapper reqW = (RequestWrapper)JSON.deserialize(reqBody, RequestWrapper.class);
            if( String.isNotBlank(reqW.clientCode) && 
               String.isNotBlank(reqW.fName) &&
               String.isNotBlank(reqW.lName) &&
               String.isNotBlank(reqW.email) &&
               String.isNotBlank(reqW.phone)          
              ){
                  list<Account> clientList = [Select Id, Client_Code__c, Application_Link__c, Name, Approved_GA__c from Account where Client_Code__c =: reqW.clientCode limit 1];
                  if( !clientList.isEmpty() ){
                      Account client = clientList[0];
                      Contact newAgent = new Contact();
                      newAgent.AccountId = client.Id;
                      newAgent.FirstName = reqW.fName;
                      newAgent.LastName = reqW.lName;
                      newAgent.Email = reqW.email;
                      newAgent.Phone = reqW.phone;
                      newAgent.Agent_Signup__c = true;
                      resW.gaApproved = clientList[0].Approved_GA__c == 'Yes' ? True : False;
                      /*String newAgentCode;
                      boolean validCode = false;
                      while( !validCode ){
                          newAgentCode = ApexCommonHelper.generateCode(10);
                          validCode = validateNewAgentCode( newAgentCode );
                      }
                      newAgentCode = newAgentCode.toUpperCase();
                      newAgent.Agent_Code__c = newAgentCode;*/
                      insert newAgent;
                      resW.isSuccess = true;
                      Contact conObj = [Select Agent_Application_Link_New__c, Agent_s_GA_Application_Link__c From Contact Where Id =: newAgent.Id Limit 1];
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
            resW.isSuccess = false;
            resW.errorMessage = ex.getMessage();
        }
        return resW;
    }
    
    /*public static String generateAgentCode(){
        Integer len = 10;
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr;
    }
    public Static boolean validateNewAgentCode(String newAgentCode){
        boolean isValid = true;
        list<Contact> conList = [Select Id from Contact where Agent_Code__c =: newAgentCode AND Agent_Code__c != null LIMIT 1 ];
        if( !conList.isEmpty() ){
            isValid = false;
        }
        return isValid;
    }*/
    
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