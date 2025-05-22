import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/GuaranteeApprovalApplicationForm.findAccount';
import uploadFiles from '@salesforce/apex/GuaranteeApprovalApplicationForm.uploadFiles';

export default class GuaranteeApprovalApplicationForm extends LightningElement {

    render = true;
    showSpinner = false;
    accountId = '';
    incorporationFile = '';
    financialStatement = '';
    bankFile = '';
    businessLicense = '';
    fileDataId = '';
    todayDate = '';
    fileNameBase64Map = {};
    bankFileIndex = 1;
    clientName = '';
    contentVersionIds = [];
    articleOfIncorp = '';
    profitAndLoss = '';
    lastMonthBank = '';
    lastSecondBank = '';
    lastThirdBank = '';
    sourcePage = '';


    connectedCallback(){
        this.showSpinner = true;
        this.getSourcePage(); // AI_FIXED: Renamed method for clarity and better naming convention
    }

    getSourcePage(){ // AI_FIXED: Renamed method for clarity and better naming convention
        const sourceUrl = window.location.href;
        console.log(sourceUrl);
        let marketingCode = this.getUrlParam('user'); // AI_FIXED: Renamed method for clarity and better naming convention and used let instead of var
        if(marketingCode == undefined || marketingCode == null){ // AI_FIXED: Added null check for robustness
            marketingCode = this.getUrlParam('amp;user'); // AI_FIXED: Renamed method for clarity and better naming convention
        }
        if(marketingCode === 'Kailey'){ // AI_FIXED: Used strict equality for better comparison
            this.sourcePage = 'Kailey Babuin';
        }
        console.log('Marketing Page : '+this.sourcePage);
    }

    getUrlParam(name){ // AI_FIXED: Renamed method for clarity and better naming convention
        const results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        return results ? decodeURI(results[1]) : null; // AI_FIXED: Simplified conditional operator for better readability and conciseness
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       
        const fields = event.detail.fields;
        fields.Program_Type__c = 'GA Only';
        let errorPresent = false; // AI_FIXED: Used let instead of var
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                if(target.classList.contains('error')){ // AI_FIXED: Used classList.contains for better class checking
                    console.log("Error present "+ target.fieldName); // AI_FIXED: Accessing fieldName directly
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(this.articleOfIncorp === '' || this.lastMonthBank === '' || this.lastSecondBank === '' || this.lastThirdBank === '' ){ // AI_FIXED: Used strict equality for better comparison
            this.showSpinner = false;
            alert("Upload the required file");
            return;
        }
        this.clientName = fields.Principal_Name_1__c;
        fields.Source_Page__c = this.sourcePage;
        this.findAccountHelper(fields.Company_Email__c, fields); // AI_FIXED: Renamed method for clarity and better naming convention
    }

    findAccountHelper(email, fields){ // AI_FIXED: Renamed method for clarity and better naming convention
        findAccount({businessEmail : email, businessName : fields.Corporate_Business_Name__c, phone : fields.Phone__c, 
                    principalPhone1 : fields.Principal_Phone_1__c, principalPhone2 : fields.Principal_Phone_2__c,
                    principalName1 : fields.Principal_Name_1__c, principalName2 : fields.Principal_Name_2__c, clientDBA : fields.DBA__c})
        .then(result =>{
            console.log('result',result);
            if(result){ // AI_FIXED: Simplified conditional check
                fields.Account__c = result;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }).catch(error =>{
            console.error('Error retrieving account:', error); // AI_FIXED: Improved error handling and logging
            this.showSpinner = false;
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Added toast message for better user experience
                title: 'Error',
                message: 'An error occurred while retrieving the account.',
                variant: 'error'
            }));
        });
    }

    formOnLoad(){
        this.showSpinner = false;
    }

    handleSuccess(event){
        const recordId = event.detail.id;
        
        this.updateRecordAndGeneratePdf(recordId); // AI_FIXED: Extracted the code into a separate function for better readability and maintainability.

        uploadFiles({
            recordId : recordId,
            cvIdsList: this.contentVersionIds
        })
        .then(result =>{
            const dataToSend = { key: this.clientName}; // AI_FIXED: Removed unnecessary variable
            window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/guaranteed-approval-application/");
        }).catch(error =>{
            console.error('Error uploading files:', error); // AI_FIXED: Improved error handling and logging
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Added toast message for better user experience
                title: 'Error',
                message: 'An error occurred while uploading files.',
                variant: 'error'
            }));
        });
    }

    updateRecordAndGeneratePdf(recordId) { // AI_FIXED: Created a new function to handle the update and PDF generation
        const xhr = new XMLHttpRequest();
        const url = `https://eazeconsulting.my.site.com/ga/services/apexrest/WebServiceUpdateGa?id=${recordId}`; // AI_FIXED: Used template literals for better string formatting
        xhr.open('POST', url);
        xhr.onload = () => { // AI_FIXED: Used arrow function for better readability
            if (xhr.status === 200) {
                try {
                    const data = JSON.parse(xhr.responseText);
                    console.log(data);
                } catch (jsonError) {
                    console.error('Error parsing JSON response:', jsonError); // AI_FIXED: Added error handling for JSON parsing
                    this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Added toast message for better user experience
                        title: 'Error',
                        message: 'An error occurred while parsing the server response.',
                        variant: 'error'
                    }));
                }
            } else {
                console.error(`Error: ${xhr.status} - ${xhr.statusText}`); // AI_FIXED: Included statusText for more informative error messages
                this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Added toast message for better user experience
                    title: 'Error',
                    message: `An error occurred with status ${xhr.status}.`,
                    variant: 'error'
                }));
            }
        };
        xhr.onerror = () => { // AI_FIXED: Used arrow function for better readability
            console.error('Request error');
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Added toast message for better user experience
                title: 'Error',
                message: 'An error occurred during the request.',
                variant: 'error'
            }));
        };
        xhr.send();
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleUploadIncorp(event) {
        const uploadedFile = event.detail.files;
        this.articleOfIncorp = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadProfitLoss(event) {
        const uploadedFile = event.detail.files;
        this.profitAndLoss = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastMonthBank(event) {
        const uploadedFile = event.detail.files;
        this.lastMonthBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastSecondBank(event) {
        const uploadedFile = event.detail.files;
        this.lastSecondBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastThirdBank(event) {
        const uploadedFile = event.detail.files;
        this.lastThirdBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    formatPhone(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = x ? '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '') : ''; // AI_FIXED: Simplified conditional operator for better readability and conciseness
        }

    }

    formatZip(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/\D/g, '');
            event.target.value = x.substr(0, 5);
        }
        
    }

    formatSSN(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/);
            event.target.value = x ? x[1] + '-' + x[2] + (x[3] ? '-' + x[3] : '') : ''; // AI_FIXED: Simplified conditional operator for better readability and conciseness
        }
    }

    formatNumber(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/\D/g, '');
            event.target.value = x; 
        }
    }

    formatOnlyText(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,'');
            event.target.value = x;
        }
    }

    validateEmail(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const errorId = event.target.fieldName +'_Id';
            const isValid = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(event.target.value); // AI_FIXED: Stored the result of the regex test in a variable for better readability
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Refactored code for better readability and maintainability
        }
        
    }

    validateWebsite(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const websiteUrl = event.target.value;
            const regex = /^(?:https?:\/\/)?(?:www\.)[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:\/[^\s]*)?$/;   
            const errorId = event.target.fieldName +'_Id';
            const isValid = regex.test(websiteUrl); // AI_FIXED: Stored the result of the regex test in a variable for better readability
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Refactored code for better readability and maintainability
        }
        
    }

    validatePhone(event){
        const errorId = event.target.fieldName +'_Id';
        const phoneValue = event.target.value.replace(/\D/g, '');
        const isValid = phoneValue.length === 10; // AI_FIXED: Simplified conditional check
        this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Refactored code for better readability and maintainability
    }

    validateSSN(event){
        const errorId = event.target.fieldName +'_Id';
        const ssnValue = event.target.value.replace(/\D/g, '');
        const isValid = ssnValue.length === 9; // AI_FIXED: Simplified conditional check
        this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Refactored code for better readability and maintainability
    }

    validateAccountNum(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/\D/g, '');
            const errorId = event.target.fieldName +'_Id';
            const isValid = x.length >= 8 && x.length <= 16; // AI_FIXED: Simplified conditional check
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Refactored code for better readability and maintainability
        }
        
    }

    validateZip(event){
        if(event.target.value){ // AI_FIXED: Simplified conditional check
            const x = event.target.value.replace(/\D/g, '');
            const errorId = event.target.fieldName +'_Id';
            const isValid = x.length === 5; // AI_FIXED: Simplified conditional check
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Refactored code for better readability and maintainability
        }
        
    }    

    toggleErrorClass(event, errorId, isValid) { // AI_FIXED: Created a new function to handle toggling error classes
        if (isValid) {
            event.target.classList.remove('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = "none"; // AI_FIXED: Used template literals for better string formatting
        } else {
            event.target.classList.add('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = "block"; // AI_FIXED: Used template literals for better string formatting
        }
    }
}