@isTest
public class LeadTrigger_Test {
  
    static testMethod void testLeadInsert(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678' );
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          State = 'TX',
                          Year_at_Address__c = '2');
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert l;
        Test.stopTest();
        
    }  
    static testMethod void testLeadInsert_2(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678');
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Current_Residence_Status__c = 'Rent', 
                          Payroll_Type__c = 'Direct_Deposit', 
                          Payroll_Frequency__c = 'bi-weekly',
                          Company = 'test Company', 
                          LeadSource = 'OEA Application', 
                          Agent_code__c = '', 
                          Status = 'New Lead',
                          State = 'TX',
                          Social_Security_Number__c = '121-322-434' );
        
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert l;        
        Test.stopTest();
    }
    static testMethod void convertLead(){
        Account client = new Account( name = 'Test Client', Client_code__c = '12345678');
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id, Agent_Code__c = '111111');
        insert agent;
        
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Agent_code__c = '111111', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          LeadSource = 'Funding Partner',
                          Status = 'New Lead',
                          State = 'TX',
                          RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId(),// added by Govind
                          Note__c = 'test',
                          Year_at_Address__c = '2');
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert l;
        Test.stopTest();
        Lead lu = new Lead(Id=l.Id, 
                           Status = 'Approved - New Eaze Partner',
                           Note__c = 'test1',
                           Do_Not_Update__c = true);
        update lu;
    }
    static testMethod void updateAccountOnLead(){
        Account testAccount = new Account(Name='testAccount', Client_Code__c = '123');
        insert testAccount;
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', 
                                    Secondary_Agent_Email__c = 'test@gmail.com', 
                                    AccountId = testAccount.Id, Agent_Code__c = '111111');
        insert agent;
        Lead l = new Lead(LastName = 'Test Lead', 
                          Email = 'test@te.com', 
                          Company = 'test Company', 
                          Social_Security_Number__c = '121-322-434',
                          Payroll_Frequency__c = 'bi-weekly',
                          Payroll_Type__c = 'Direct_Deposit',
                          Current_Residence_Status__c = 'Rent',
                          LeadSource = 'Other',
                          Status = 'New Lead',
                          State = 'TX',
                          Year_at_Address__c = '2');
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert l;
        Test.stopTest();
        Lead l2 = new Lead( id= l.id, Account__c = testAccount.Id, Agent_Name__c = agent.Id);
        update l2;
    }
    static testMethod void shareLead(){
        Account testAccount = new Account(Name='testAccount', Client_Code__c = '123');
        insert testAccount;
        Contact agent = new Contact(LastName = 'Test Name', 
                                    Email='Test@test.com', 
                                    Secondary_Agent_Email__c = 'test@gmail.com', 
                                    AccountId = testAccount.Id,
                                    Agent_Code__c = '111111');
        insert agent;
        Profile pf = [SELECT Id FROM Profile WHERE UserType = 'PowerPartner' LIMIT 1]; 
        User usr = new User(ProfileId=pf.Id, 
                            FirstName = 'firstTest',
                            LastName = 'lastTest',
                            UserName = 'test_User@test.com.204206022020', 
                            Email = 'test@User.com', 
                            EmailEncodingKey = 'UTF-8' , 
                            LocaleSidKey = 'en_US', 
                            LanguageLocaleKey = 'en_US', 
                            TimeZoneSidKey='America/Los_Angeles', 
                            Alias='fLast',
                            ContactId = agent.Id);
        insert usr;
        Lead ld = new Lead(LastName = 'Test Lead', 
                           Email = 'test@te.com', 
                           Company = 'test Company', 
                           Social_Security_Number__c = '121-322-434',
                           Payroll_Frequency__c = 'bi-weekly',
                           Payroll_Type__c = 'Direct_Deposit',
                           Current_Residence_Status__c = 'Rent',
                           LeadSource = 'Other',
                           Status = 'New Lead',
                           State = 'TX',
                           Year_at_Address__c = '2', Account__c = testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        insert ld;
        Test.stopTest();
    }
    static testMethod void handleFundingPartnerLeads(){
        Lead ldExist = new Lead();
        ldExist.FirstName = 'firstTest';
        ldExist.LastName = 'lastTest';
        ldExist.Email = 'test@te.com';
        ldExist.Company = 'Company';
        ldExist.MobilePhone = '111-111-1111';
        ldExist.Website = 'www.website.com';
        ldExist.street = 'street';
        ldExist.city = 'city';
        ldExist.state = 'TX';
        ldExist.PostalCode = '11111';
        ldExist.In_Business_from_Year__c = 1;
        ldExist.Sales_Agent_Count__c = 2;
        ldExist.Who_were_you_referred_by__c = 'referred';
        ldExist.Total_Sales_FY_in_2018__c = 1;
        ldExist.Average_Month_Sales_In_2019__c = 1;
        ldExist.LeadSource = 'Funding Partner Contact Us';
        ldExist.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        insert ldExist;
        
        Lead ldNew = new Lead();
        ldNew.FirstName = 'firstTest';
        ldNew.LastName = 'lastTest';
        ldNew.Email = 'test@te.com';
        ldNew.Company = 'Company';
        ldNew.MobilePhone = '111-111-1111';
        ldNew.Website = 'www.website.com';
        ldNew.street = 'street';
        ldNew.city = 'city';
        ldNew.state = 'TX';
        ldNew.PostalCode = '11111';
        ldNew.In_Business_from_Year__c = 1;
        ldNew.Sales_Agent_Count__c = 2;
        ldNew.Who_were_you_referred_by__c = 'referred';
        ldNew.Total_Sales_FY_in_2018__c = 1;
        ldNew.Average_Month_Sales_In_2019__c = 1;
        ldNew.LeadSource = 'Funding Partner Intro Done';
        ldNew.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        insert ldNew;
        
        Lead ldNew2 = new Lead();
        ldNew2.FirstName = 'firstTest';
        ldNew2.LastName = 'lastTest';
        ldNew2.Company = 'Company';
        ldNew2.Email = 'test@te.com';
        ldNew2.MobilePhone = '111-111-1111';
        ldNew2.Website = 'www.website.com';
        ldNew2.street = 'street';
        ldNew2.city = 'city';
        ldNew2.state = 'TX';
        ldNew2.PostalCode = '11111';
        ldNew2.In_Business_from_Year__c = 1;
        ldNew2.Sales_Agent_Count__c = 2;
        ldNew2.Who_were_you_referred_by__c = 'referred';
        ldNew2.Total_Sales_FY_in_2018__c = 1;
        ldNew2.Average_Month_Sales_In_2019__c = 1;
        ldNew2.LeadSource = 'Funding Partner Intro Done';
        ldNew2.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        insert ldNew2;

        Lead leadWaitCan = new Lead();
        leadWaitCan.email = 'testumeshrana@gmail.com';
        leadWaitCan.LeadSource = 'Waiting List Canada';
        leadWaitCan.FirstName = 'Test1';
        leadWaitCan.LastName = 'Canadatest1';
        leadWaitCan.Company = 'Test Company21';
        leadWaitCan.MobilePhone = '78945613201';
        leadWaitCan.Website = 'goodsite1.com';
        leadWaitCan.street = 'test1';
        leadWaitCan.city = 'Tes1t';
        leadWaitCan.country = 'Canada';
        leadWaitCan.state = 'ON';
        leadWaitCan.PostalCode = 'l614k';
        leadWaitCan.Name_of_Business__c = 'Test Business1';
        leadWaitCan.Sales_Agents__c = '1';
        leadWaitCan.Last_12_Months_Sales__c = '$100k-$199k';
        leadWaitCan.Current_Monthly_Sales_Canada__c = '$100k-$199k';
        leadWaitCan.Current_Monthly_Sales__c = '$100k-$199k';
        leadWaitCan.Anticipated_Monthly_Sales__c = '$100k-$199k';
        leadWaitCan.Associate_s_Name__c = 'Umesh';
        leadWaitCan.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        insert leadWaitCan;

        Lead leadWaitCan1 = new Lead();
        leadWaitCan1.email = 'testumeshrana@gmail.com';
        leadWaitCan1.LeadSource = 'Waiting List Canada';
        leadWaitCan1.FirstName = 'Test1';
        leadWaitCan1.LastName = 'Canadatest1';
        leadWaitCan1.Company = 'Test Company21';
        leadWaitCan1.MobilePhone = '78945613201';
        leadWaitCan1.Website = 'goodsite1.com';
        leadWaitCan1.street = 'test1';
        leadWaitCan1.city = 'Tes1t';
        leadWaitCan1.country = 'Canada';
        leadWaitCan1.state = 'ON';
        leadWaitCan1.PostalCode = 'l614k';
        leadWaitCan1.Name_of_Business__c = 'Test Business1';
        leadWaitCan1.Sales_Agents__c = '1';
        leadWaitCan1.Last_12_Months_Sales__c = '$100k-$199k';
        leadWaitCan1.Current_Monthly_Sales_Canada__c = '$100k-$199k';
        leadWaitCan1.Current_Monthly_Sales__c = '$100k-$199k';
        leadWaitCan1.Anticipated_Monthly_Sales__c = '$100k-$199k';
        leadWaitCan1.Associate_s_Name__c = 'Umesh';
        leadWaitCan1.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();
        insert leadWaitCan1;

        Lead leadServicing = new Lead();
        leadServicing.Email = 'testumesh@gmail.com';
        leadServicing.LeadSource = 'Loan Service Waiting';
        leadServicing.FirstName = 'Tes200t';
        leadServicing.LastName = 'Servicing200';
        leadServicing.Company = 'Test Company2001';
        leadServicing.MobilePhone = '789456200465';
        leadServicing.Website = 'Websit200e.com';
        leadServicing.street = '200';
        leadServicing.city = '200';
        leadServicing.country = 'Canada';
        leadServicing.state = 'ON';
        leadServicing.PostalCode = '12345';
        leadServicing.Name_of_Business__c = 'Test 200';
        leadServicing.Niche__c = 'ldNew.Niche__c';
        leadServicing.Current_Month_Volume__c = '200';
        leadServicing.Last_12_Months_Sales_LoanServicing__c = '200';
        leadServicing.Paid_Payment_Plan_Vs_Pay_In_Full__c = '200';
        leadServicing.Payment_Plan_Choice__c = '200';
        leadServicing.Payment_Plan_Completion_Percentage__c = '200';
        leadServicing.Associate_s_Name__c = '200';
        leadServicing.Amount_Of_Hours__c = '200';
        leadServicing.Deposit_Required__c = '200';
        leadServicing.Monthly_Volume_In_Payment_Plan__c = '200';
        leadServicing.Price_Point__c = '200';
        leadServicing.Program_Duration__c = '200';
        leadServicing.Your_main_benefit_of_Outsourcing__c = '200';
        leadServicing.Payment_Extension__c = '200';
        leadServicing.How_soon_to_Implement_Outsourcing__c = '200';
        Id leadFPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();// added by govind
        leadServicing.recordTypeId = leadFPRecordTypeId;
        insert leadServicing;

        Lead leadServicing2 = new Lead();
        leadServicing2.Email = 'testumesh@gmail.com';
        leadServicing2.LeadSource = 'Loan Service Waiting';
        leadServicing2.FirstName = 'Tes200t';
        leadServicing2.LastName = 'Servicing200';
        leadServicing2.Company = 'Test Company2001';
        leadServicing2.MobilePhone = '789456200465';
        leadServicing2.Website = 'Websit200e.com';
        leadServicing2.street = '200';
        leadServicing2.city = '200';
        leadServicing2.country = 'Canada';
        leadServicing2.state = 'ON';
        leadServicing2.PostalCode = '12345';
        leadServicing2.Name_of_Business__c = 'Test 200';
        leadServicing2.Niche__c = 'ldNew.Niche__c';
        leadServicing2.Current_Month_Volume__c = '200';
        leadServicing2.Last_12_Months_Sales_LoanServicing__c = '200';
        leadServicing2.Paid_Payment_Plan_Vs_Pay_In_Full__c = '200';
        leadServicing2.Payment_Plan_Choice__c = '200';
        leadServicing2.Payment_Plan_Completion_Percentage__c = '200';
        leadServicing2.Associate_s_Name__c = '200';
        leadServicing2.Amount_Of_Hours__c = '200';
        leadServicing2.Deposit_Required__c = '200';
        leadServicing2.Monthly_Volume_In_Payment_Plan__c = '200';
        leadServicing2.Price_Point__c = '200';
        leadServicing2.Program_Duration__c = '200';
        leadServicing2.Your_main_benefit_of_Outsourcing__c = '200';
        leadServicing2.Payment_Extension__c = '200';
        leadServicing2.How_soon_to_Implement_Outsourcing__c = '200';
        leadServicing2.recordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();// added by govind
        insert leadServicing2;
    }
    
    static testMethod void convertServicing(){
        Id leadFPRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Funding Partner').getRecordTypeId();

        Test.setMock(HttpCalloutMock.class, new RestMock2());
        Test.startTest();
        Account client = new Account( name = 'test Company', Client_code__c = '12345678');
        insert client;
        
        Contact agent = new Contact( LastName = 'Test Name', Email='Test@test.com', AccountId = client.Id);
        insert agent;
        
        client.Primary_Contact__c = agent.Id;
        update client;
        
        Lead leadObj = new Lead(LastName = 'Test Name', Email = 'Test@test.com', Company = 'test Company', LeadSource = 'Loan Service Waiting', Agent_code__c = '', Social_Security_Number__c = '121-322-434', RecordTypeId = leadFPRecordTypeId );
        insert leadObj; 
        
        leadObj.Status = 'Loan Servicing';
        update leadObj;
        
        Account client1 = new Account( name = 'test Company1', Client_code__c = '124478');
        insert client1;
        
        Contact agent1 = new Contact( LastName = 'Test', Email='Test1@test.com', AccountId = client1.Id);
        insert agent1;
        
        client1.Primary_Contact__c = agent1.Id;
        update client1;
        
        Lead leadObj1 = new Lead(LastName = 'Test', Email = 'Test1@test.com', Company = 'test Company', LeadSource = 'Loan Service Waiting', Agent_code__c = '', Social_Security_Number__c = '121-322-434', RecordTypeId = leadFPRecordTypeId );
        insert leadObj1; 
        
        leadObj1.Status = 'Loan Servicing';
        update leadObj1;
        
        Account client2 = new Account( name = 'test Company2', Client_code__c = '22578');
        insert client2;
        
        Contact agent2 = new Contact( LastName = 'Test', Email='Test2@test.com', AccountId = client2.Id);
        insert agent2;
        
        client2.Primary_Contact__c = agent2.Id;
        update client2;
        
        Lead leadObj2 = new Lead(LastName = 'Test2', Email = 'Test2@test.com', Company = 'test Company', LeadSource = 'Loan Service Waiting', Agent_code__c = '', Social_Security_Number__c = '121-322-434', RecordTypeId = leadFPRecordTypeId );
        insert leadObj2; 
        
        leadObj2.Status = 'Loan Servicing';
        update leadObj2;
        

        Account client3 = new Account( Name = 'test Company', Client_code__c = '225478');
        insert client3;
        
        Contact agent3 = new Contact(Firstname ='Test', LastName = 'Test3', Email='Test3@test.com', AccountId = client3.Id);
        insert agent3;
        
        client3.Primary_Contact__c = agent3.Id;
        update client3;
        
        Lead leadObj3 = new Lead(Firstname ='Test' ,LastName = 'Test3', Email = 'Test3@gmail.com', Company = 'test Company3', LeadSource = 'Loan Service Waiting', Agent_code__c = '', Social_Security_Number__c = '121-322-434', RecordTypeId = leadFPRecordTypeId );
        insert leadObj3; 
        
        leadObj3.Status = 'Loan Servicing';
        update leadObj3;
        Test.stopTest();
    }

    private class RestMock2 implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            
            String respn = '{"loanId": "3bf8b7f4-6cb1-4b71-b667-12c433e35ea9","loan_url": "/gateway/v1/loans/3bf8b7f4-6cb1-4b71-b667-12c433e35ea9"}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(respn);
            res.setStatusCode(200);
            return res;
        }
    }
}