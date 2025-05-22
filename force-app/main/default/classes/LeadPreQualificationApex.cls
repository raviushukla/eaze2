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
        String apiNames = ApexCommonHelper.getAllField('Lead');
        String queryOnLead = 'Select '+apiNames+' from Lead where id =: leadId';
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
                String reqBody = '';
                String errorLog = '';
                system.debug(mapCustmDataPostParam);
                system.debug(mapCustmDataDefaultValue);
                for(String strPreField : mapCustmDataPostParam.keyset()){
                    if(String.isNotBlank( reqBody ) ){
                        reqBody = reqBody+'&'; 
                    }
                    String paramVal = mapCustmDataPostParam.get( strPreField );
                    Object leadVal = l.get( paramVal );
                    if( strPreField == 'dob' ){
                        Date dob = (Date)leadVal;
                        if( dob != null ){
                            String strDate = ( dob.month() <10 ? '0'+dob.month() : String.valueOf( dob.month() ) ) + 
                                             ( dob.day() < 10 ? '0'+dob.day() : String.valueOf( dob.day() ) ) +
                                             String.valueOf( dob.year() );
                            reqBody += strPreField+'='+EncodingUtil.urlEncode(strDate,'UTF-8');
                        }
                    }
                    else if( strPreField == 'phone'  ){
                        if( leadVal != null && String.isNotBlank( (String)leadVal ) ){
                            String strPhone = (String)leadVal;
                            strPhone = formatString( strPhone );
                            reqBody += strPreField+'='+EncodingUtil.urlEncode(strPhone,'UTF-8');
                        }else{
                            errorLog += strPreField+' is required field.\n';
                        }
                    }
                    else if(strPreField == 'ssn' || strPreField == 'ssn2'){
                        if( leadVal != null && String.isNotBlank( (String)leadVal) ){
                            String strSSN = (String)leadVal;
                            strSSN = formatString( strSSN );
                            reqBody += strPreField+'='+EncodingUtil.urlEncode(strSSN,'UTF-8');
                        }else{
                            errorLog += StrPreField+' is required field.\n';
                        }
                    }
                    else{
                        if( leadVal != null && String.isNotBlank( (String)leadVal) ){
                            String strLeadVal = (String)leadVal ;
                            reqBody += strPreField+'='+EncodingUtil.urlEncode( strLeadVal ,'UTF-8');
                        }else if( strPreField != 'middlename' ) {
                            errorLog += strPreField+' is required field.\n';
                        }
                    }
                    system.debug('strPreField='+strPreField+' '+leadVal);
                }
                for( String strPreField : mapCustmDataDefaultValue.keySet() ){
                    List<String> DefVal = label.PreQual_Default_Fields.split(',');
                    if( DefVal.contains(strPreField) ){
                        String dValue = mapCustmDataDefaultValue.get(strPreField);
                        if( String.isNotBlank( dValue ) ){
                            reqBody += '&'+strPreField+'='+EncodingUtil.urlEncode(dValue,'UTF-8');
                        }else{
                            errorLog += strPreField+' is required.\n';
                        }
                    }
                }
                System.debug('reqBody='+reqBody);
                if( String.isNotBlank(reqBody) && String.isBlank(errorLog)  ){
                    HttpResponse response = RESTCalloutHelper.makeCallout(reqMethod,reqBody,reqEndPoint,reqHeaders);
                    String resBody = response.getBody();
                    system.debug('resBody'+resBody);
                    if(response.getStatus() == 'OK' && response.getStatusCode() == 200){
                        resBody = resBody.toLowerCase();
                        if( mapCustmDataDefaultValue.containsKey( resBody ) ){
                            errorLog += resBody+' : '+ mapCustmDataDefaultValue.get(resBody)+'\n';
                            if( l.ErrorLog__c == null ){
                                l.ErrorLog__c = '';
                            }
                            l.ErrorLog__c += errorLog;
                            returnbody = errorLog;
                        }else if(resBody.length() == 32){
                            l.PREQUAL_ID__c = resBody;
                            returnbody = '';
                        }else{
                            if( l.ErrorLog__c == null ){
                                l.ErrorLog__c = '';
                            }
                            l.ErrorLog__c += errorLog;
                            returnbody = errorLog;
                        } 
                    }else{
                        errorLog += response.getStatus()+', '+resBody+'\n';
                        if( l.ErrorLog__c == null ){
                            l.ErrorLog__c = '';
                        }
                        l.ErrorLog__c += errorLog;
                        returnbody = errorLog;
                    }
                }else{
                    if( l.ErrorLog__c == null ){
                        l.ErrorLog__c = '';
                    }
                    l.ErrorLog__c += errorLog;
                }
            }catch( Exception ex ){
                if( l.ErrorLog__c == null ){
                    l.ErrorLog__c = '';
                }
                l.ErrorLog__c += ex.getMessage();
            }
            update l;
        }
        return returnbody;
    }
    public Static String FormatString(String changeformat){
        changeformat = changeformat.replace('(','').replace(')','').replace(' ','').replace('-','').replaceAll('-','');
        return changeformat;
        
    }
}