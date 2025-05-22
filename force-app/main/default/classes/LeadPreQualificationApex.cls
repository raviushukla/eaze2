/* ***************************************************************************
 * Created date: Apr 23, 2019
 * Auther: Pawan Makkar
 * Des: This is SOAP webservice class, called from button on lead
 * ---------------------------------
 * Change 1;
 * Date: Apr 26, 2019
 * Auther: JAI SINGH
 * Des: Modification in code for optimal use
 * ----------------------------------
 * Change 1;
 * Date: Jan 11, 2024
 * Auther: UMESH RANA
 * Des: Modification in code for Prequal Id number of characters
 * ***************************************************************************/

global class LeadPreQualificationApex {
    
    //POST Method to make callout to PreQaul API
    webservice static String LeadPreQualificationPost( String leadId ){
        String returnbody = '';
        // AI_FIXED: Prevent SOQL injection vulnerability by using bind variables instead of string concatenation.
        String queryOnLead = 'Select Id, FirstName, LastName, Email, Phone, Birthdate, SocialSecurityNumber from Lead where Id = :leadId'; 
        list<lead> leadList = database.Query(queryOnLead);
        if( leadList != null && !leadList.isEmpty() ){
            Lead l = leadList[0];
            try{
                map<String,String> mapCustmDataPostParam = new map<String,String>();
                map<String,String> mapCustmDataDefaultValue = new map<String,String>();
                
                for(PREQUAL_APP_DATA__mdt PREQUAL : [Select DeveloperName, MasterLabel,Body_Data_Field_Name__c,
                                                             Default_Value__c,Lead_Field_API_Mapping__c from PREQUAL_APP_DATA__mdt] ){
                    if(String.isNotBlank(PREQUAL.Lead_Field_API_Mapping__c)){
                        mapCustmDataPostParam.put(PREQUAL.Body_Data_Field_Name__c, PREQUAL.Lead_Field_API_Mapping__c);
                    }else{
                        mapCustmDataDefaultValue.put(PREQUAL.Body_Data_Field_Name__c, PREQUAL.Default_Value__c);
                    }
                }
                
                String reqEndPoint = mapCustmDataDefaultValue.get('LoanPreQualificationEndPoint');
                String reqMethod = mapCustmDataDefaultValue.get('LoanPreQualificationMethod');
                map<String,String> reqHeaders = new map<String,String>();
                reqHeaders.put('Content-Type','application/x-www-form-urlencoded');
                // AI_FIXED: Use StringBuilder for efficient string concatenation.
                StringBuilder reqBody = new StringBuilder();
                String errorLog = '';
                system.debug(mapCustmDataPostParam);
                system.debug(mapCustmDataDefaultValue);
                for(String strPreField : mapCustmDataPostParam.keyset()){
                    // AI_FIXED: Improved null and blank checks and handling.
                    String paramVal = mapCustmDataPostParam.get( strPreField );
                    Object leadVal = l.get( paramVal );
                    if(leadVal == null) {
                        if(strPreField != 'middlename') {
                            errorLog += strPreField+' is required field.\n';
                        }
                        continue;
                    }
                    if( strPreField == 'dob' ){
                        Date dob = (Date)leadVal;
                        if( dob != null ){
                            String strDate = ( dob.month() <10 ? '0'+dob.month() : String.valueOf( dob.month() ) ) + 
                                             ( dob.day() < 10 ? '0'+dob.day() : String.valueOf( dob.day() ) ) +
                                             String.valueOf( dob.year() );
                            reqBody.append(strPreField).append('=').append(EncodingUtil.urlEncode(strDate,'UTF-8'));
                        }
                    }
                    else if( strPreField == 'phone'  ){
                        String strPhone = (String)leadVal;
                        strPhone = formatString( strPhone );
                        reqBody.append(strPreField).append('=').append(EncodingUtil.urlEncode(strPhone,'UTF-8'));
                    }
                    else if(strPreField == 'ssn' || strPreField == 'ssn2'){
                        String strSSN = (String)leadVal;
                        strSSN = formatString( strSSN );
                        reqBody.append(strPreField).append('=').append(EncodingUtil.urlEncode(strSSN,'UTF-8'));
                    }
                    else{
                        String strLeadVal = (String)leadVal ;
                        reqBody.append(strPreField).append('=').append(EncodingUtil.urlEncode( strLeadVal ,'UTF-8'));
                    }
                    // AI_FIXED: Removed unnecessary debug statement.
                    //system.debug('strPreField='+strPreField+' '+leadVal);
                    if(reqBody.length() > 0 && reqBody.indexOf("&") == -1) {
                        reqBody.insert(0, "&");
                    }
                }
                for( String strPreField : mapCustmDataDefaultValue.keySet() ){
                    List<String> DefVal = label.PreQual_Default_Fields.split(',');
                    if( DefVal.contains(strPreField) ){
                        String dValue = mapCustmDataDefaultValue.get(strPreField);
                        if( String.isNotBlank( dValue ) ){
                            reqBody.append('&').append(strPreField).append('=').append(EncodingUtil.urlEncode(dValue,'UTF-8'));
                        }else{
                            errorLog += strPreField+' is required.\n';
                        }
                    }
                }
                // AI_FIXED: Removed unnecessary debug statement.
                //System.debug('reqBody='+reqBody);
                if( reqBody.length() > 0 && String.isBlank(errorLog)  ){
                    HttpResponse response = RESTCalloutHelper.makeCallout(reqMethod,reqBody.toString(),reqEndPoint,reqHeaders);
                    String resBody = response.getBody();
                    // AI_FIXED: Removed unnecessary debug statement.
                    //system.debug('resBody'+resBody);
                    if(response.getStatusCode() == 200){
                        resBody = resBody.toLowerCase();
                        if( mapCustmDataDefaultValue.containsKey( resBody ) ){
                            errorLog += resBody+' : '+ mapCustmDataDefaultValue.get(resBody)+'\n';
                            l.ErrorLog__c = (l.ErrorLog__c == null) ? '' : l.ErrorLog__c; // AI_FIXED: Simplified null check for ErrorLog__c
                            l.ErrorLog__c += errorLog;
                            returnbody = errorLog;
                        }else if(resBody.length() == 32){
                            l.PREQUAL_ID__c = resBody;
                            returnbody = '';
                        }else{
                            l.ErrorLog__c = (l.ErrorLog__c == null) ? '' : l.ErrorLog__c; // AI_FIXED: Simplified null check for ErrorLog__c
                            l.ErrorLog__c += errorLog;
                            returnbody = errorLog;
                        } 
                    }else{
                        errorLog += response.getStatus()+', '+resBody+'\n';
                        l.ErrorLog__c = (l.ErrorLog__c == null) ? '' : l.ErrorLog__c; // AI_FIXED: Simplified null check for ErrorLog__c
                        l.ErrorLog__c += errorLog;
                        returnbody = errorLog;
                    }
                }else{
                    l.ErrorLog__c = (l.ErrorLog__c == null) ? '' : l.ErrorLog__c; // AI_FIXED: Simplified null check for ErrorLog__c
                    l.ErrorLog__c += errorLog;
                }
            }catch( Exception ex ){
                l.ErrorLog__c = (l.ErrorLog__c == null) ? '' : l.ErrorLog__c; // AI_FIXED: Simplified null check for ErrorLog__c
                l.ErrorLog__c += ex.getMessage();
            }
            update l;
        }
        return returnbody;
    }
    public Static String FormatString(String changeformat){
        // AI_FIXED: Removed redundant replace call.
        changeformat = changeformat.replace('(','').replace(')','').replace(' ','').replace('-','');
        return changeformat;
        
    }
}