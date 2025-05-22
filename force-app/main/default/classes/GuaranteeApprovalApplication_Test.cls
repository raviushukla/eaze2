@isTest
public class GuaranteeApprovalApplication_Test {
	
    testMethod static void setAccount(){
		
		Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;

		client.Primary_Contact__c = agent.Id;
		update client;
		
		system.assertEquals(String.valueOf(client.Id), GuaranteeApprovalApplication.findAccount('Test@test.com'));      
        system.assertNotEquals(String.valueOf(client.Id), GuaranteeApprovalApplication.findAccount('Test@test.c'));    
    }
    
    testMethod static void uploadDoc(){
		
        Guaranteed_Approval_Application__c obj = new Guaranteed_Approval_Application__c();
        insert obj;
        Map<Object, String> fileMap = new Map<Object, String>();
        fileMap.put('file1.txt', EncodingUtil.base64Encode(Blob.valueOf('File 1 content')));
        
		GuaranteeApprovalApplication.uploadFiles(obj.Id,fileMap);
    }
}