// Umesh Rana 14-09-2023
// This class is called from a LWC Cmp (createAccAndContactForGA), which is called from a VF page (CreateAccountAndContact).
// Test Class - CreateAccAndContactForGA_Test
public with sharing class CreateAccAndContactForGA {
    
    @AuraEnabled
    public static CreateAccAndContactForGA.accWrap createAccConRecord(String gaId){
        
        String name = '';

        CreateAccAndContactForGA.accWrap accWrapObj = new CreateAccAndContactForGA.accWrap();

        Guaranteed_Approval_Application__c gaObj = [Select Id, Corporate_Business_Name__c, Company_Website__c, Been_In_Business_Years__c, 
                                                    Number_of_Sales_Agent__c, Total_Sales_For_2023__c, Address__c, City__c, State__c, Zip__c, Source_Page__c,
                                                    Company_Email__c, Program_Type__c, Phone__c, Principal_Name_1__c, Principal_Name_2__c, Principal_Phone_1__c, Principal_Phone_2__c
                                                    From Guaranteed_Approval_Application__c 
                                                    Where Id=: gaId];
        
        List<Account> accList = [Select Id, Name, Primary_Contact__r.Name from Account Where Primary_Contact__c != null 
                                 AND ((Primary_Contact_Email_Formula__c =: gaObj.Company_Email__c AND Primary_Contact_Email_Formula__c != null) 
                                 OR ((Primary_Contact_Phone__c =: gaObj.Principal_Phone_1__c OR Primary_Contact_Phone__c =: gaObj.Principal_Phone_2__c OR Primary_Contact_Phone__c =: gaObj.Phone__c) AND Primary_Contact_Phone__c != null) 
                                 OR Name =: gaObj.Corporate_Business_Name__c
                                 OR (Primary_Contact__r.Name =: gaObj.Principal_Name_1__c OR Primary_Contact__r.Name =: gaObj.Principal_Name_2__c)) LIMIT 1];
        if(accList.size() > 0){
            accWrapObj.accName = accList[0].Name;
            accWrapObj.contactName = accList[0].Primary_Contact__r.Name;
            accWrapObj.accPresent = true;
            return accWrapObj;
        }
        
        Account acc = new Account();
        acc.Name = gaObj.Corporate_Business_Name__c;
        acc.Website = gaObj.Company_Website__c;
        acc.In_Business_from_Year__c = gaObj.Been_In_Business_Years__c;
        acc.Sales_Agent_Count__c = gaObj.Number_of_Sales_Agent__c;
        acc.Total_Sales_In_FY__c = gaObj.Total_Sales_For_2023__c;
        acc.BillingStreet = gaObj.Address__c;
        acc.BillingCity = gaObj.City__c;
        acc.BillingState = gaObj.State__c;
        acc.BillingPostalCode = gaObj.Zip__c;
        acc.Program_Type__c = gaObj.Program_Type__c == 'GA Only' ? 'GA Only': '' ;
        acc.Source_Page__c = gaObj.Source_Page__c != null ? gaObj.Source_Page__c : '' ;
        insert acc;
        Contact con = new Contact();
        List<String> contactName = gaobj.Principal_Name_1__c.split(' ');
        if(contactName.size() > 1){
            for(Integer i = 0;i < contactName.size() -1; i++){
                if(con.FirstName == null || con.FirstName == ''){
                    con.FirstName = contactName[i];
                    name = contactName[i];
                }else{
                    con.FirstName += ' ' + contactName[i];
                }
            }
            con.LastName = contactName[contactName.size() -1];
        }else{
            con.LastName = gaobj.Principal_Name_1__c;
            name = gaobj.Principal_Name_1__c;
        }
        con.AccountId = acc.Id;
        con.Email = gaObj.Company_Email__c;
        con.MailingStreet = gaObj.Address__c;
        con.MailingCity = gaObj.City__c;
        con.MailingState = gaObj.State__c;
        con.MailingPostalCode = gaObj.Zip__c;
        con.MobilePhone = gaObj.Phone__c;
        con.Is_Primary__c = true;
        con.Password__c = name+'1$';
        insert con;

        acc.Primary_Contact__c=con.Id; 
        acc.Primary_Contact_Email__c=con.Email;
        acc.Primary_Contact_Name__c=con.Name;
        update acc;

        gaObj.Account__c = acc.Id;
        update gaObj;

        accWrapObj.accPresent = false;
        return accWrapObj;
    }

    public class accWrap {
        @AuraEnabled public String contactName;
        @AuraEnabled public String accName;
        @AuraEnabled public Boolean accPresent;
    }
}