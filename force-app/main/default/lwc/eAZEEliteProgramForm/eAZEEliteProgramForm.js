import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/EazeEliteProgramForm.findAccount';
import uploadFiles from '@salesforce/apex/EazeEliteProgramForm.uploadFiles';

export default class EAZEEliteProgramForm extends LightningElement {
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
        this.getSourcePage(); // AI_FIXED: Renamed method for clarity and consistency
    }

    getSourcePage(){
        const sourceUrl = window.location.href;
        // AI_FIXED: Use const for sourceUrl as it's not reassigned.
        console.log(sourceUrl);
        let marketingCode = this.getUrlParam('user'); // AI_FIXED: Renamed method for clarity and consistency
        // AI_FIXED: Use let for marketingCode as it might be reassigned.
        if(marketingCode == null){ // AI_FIXED: Use null check instead of undefined and empty string check.
            marketingCode = this.getUrlParam('amp;user');
        }
        if(marketingCode === 'Kailey'){ // AI_FIXED: Use strict equality (===) for comparison.
            this.sourcePage = 'Kailey Babuin';
        }
        console.log('Marketing Page : '+this.sourcePage);
    }

    getUrlParam(name){
        const results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href); // AI_FIXED: Use const for results as it's not reassigned.
        return results ? decodeURI(results[1]) : null; // AI_FIXED: Simplified conditional operator.
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Program_Type__c = 'GA Only';
        let errorPresent = false; // AI_FIXED: Use let for errorPresent as it's reassigned.
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                if(target.classList.contains('error')){ // AI_FIXED: Use classList.contains for better performance and readability.
                    console.log("Error present "+ target.fieldName); // AI_FIXED: Access fieldName directly.
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(this.lastMonthBank === '' || this.lastSecondBank === '' || this.lastThirdBank === '' ){ // AI_FIXED: Use strict equality (===) for comparison.
            this.showSpinner = false;
            alert("Upload the required file");
            return;
        }
        this.clientName = fields.Name__c;
        fields.Source_Page__c = this.sourcePage;
        this.findAccountHelper(fields.Company_Email__c, fields); // AI_FIXED: Renamed method for clarity and consistency
    }

    findAccountHelper(email, fields){
        findAccount({
            businessEmail: email, 
            businessName: fields.Corporate_Business_Name__c,
            phone: fields.Phone1__c, 
            principalName1: fields.Name__c, 
            clientDBA: fields.DBA__c
        })
        .then(result => {
            if(result) { // AI_FIXED: Simplified null check.
                fields.Account__c = result;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        })
        .catch(error => {
            console.error('Error finding account:', error);
            this.handleError(error); // AI_FIXED: Call the dedicated error handling method.
        })
        .finally(() => {
            this.showSpinner = false; 
        });
    }

    handleFormLoad(){ // AI_FIXED: Renamed method for clarity and consistency
        this.showSpinner = false;
    }

    handleError(error){ // AI_FIXED: Added a dedicated error handling method.
        console.error('Error:', error);
        // AI_FIXED:  Implement more robust error handling here, e.g., display a user-friendly message.
        this.showSpinner = false;
        alert('An error occurred. Please try again later.');
    }

    handleSuccess(event){
        const recordId = event.detail.id;
        console.log('Content Version IDs:', this.contentVersionIds);
        console.log('Uploading files to record:', recordId);
        uploadFiles({
            recordId, // AI_FIXED: Simplified property assignment.
            cvIdsList: this.contentVersionIds
        })
        .then(result =>{
            const dataToSend = { key: this.clientName }; // AI_FIXED: Simplified object creation.
            window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/eaze-elite-application/");
            window.location.href = "https://www.eazeconsulting.com/eaze-elite-application/";
        })
        .catch(error =>{
            this.handleError(error); // AI_FIXED: Call the dedicated error handling method.
        })
        .finally(() => {
            this.showSpinner = false; 
        });
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleUploadLastMonthBank(event) {
        const uploadedFile = event.detail.files; // AI_FIXED: Use const for uploadedFile as it's not reassigned.
        this.lastMonthBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastSecondBank(event) {
        const uploadedFile = event.detail.files; // AI_FIXED: Use const for uploadedFile as it's not reassigned.
        this.lastSecondBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastThirdBank(event) {
        const uploadedFile = event.detail.files; // AI_FIXED: Use const for uploadedFile as it's not reassigned.
        this.lastThirdBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    formatPhone(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/); // AI_FIXED: Use const for x as it's not reassigned.
            event.target.value = x ? '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '') : ''; // AI_FIXED: Simplified conditional operator and added empty string for null case.
        }

    }

    formatZip(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, ''); // AI_FIXED: Use const for x as it's not reassigned.
            event.target.value = x.substr(0, 5);
        }
        
    }

    formatSSN(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/); // AI_FIXED: Use const for x as it's not reassigned.
            event.target.value = x ? x[1] + '-' + x[2] + (x[3] ? '-' + x[3] : '') : ''; // AI_FIXED: Simplified conditional operator and added empty string for null case.
        }
    }

    formatNumber(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, ''); // AI_FIXED: Use const for x as it's not reassigned.
            event.target.value = x; 
        }
    }

    formatOnlyText(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,''); // AI_FIXED: Use const for x as it's not reassigned.
            event.target.value = x;
        }
    }

    validateEmail(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const errorId = event.target.fieldName +'_Id'; // AI_FIXED: Use const for errorId as it's not reassigned.
            const isValid = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(event.target.value); // AI_FIXED: Use const for isValid and simplified regex test.
            this.toggleErrorClass(event.target, errorId, !isValid); // AI_FIXED: Use helper method for better code organization.
        }
        
    }

    validateWebsite(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const websiteUrl = event.target.value;
            const regex = /^(?:https?:\/\/)?(?:www\.)[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:\/[^\s]*)?$/;   
            const errorId = event.target.fieldName +'_Id'; // AI_FIXED: Use const for errorId as it's not reassigned.
            const isValid = regex.test(websiteUrl); // AI_FIXED: Use const for isValid and simplified regex test.
            this.toggleErrorClass(event.target, errorId, !isValid); // AI_FIXED: Use helper method for better code organization.
        }
        
    }

    validatePhone(event){
        const errorId = event.target.fieldName +'_Id'; // AI_FIXED: Use const for errorId as it's not reassigned.
        const phoneValue = event.target.value; // AI_FIXED: Use const for phoneValue as it's not reassigned.
        const isValid = phoneValue.length === 10 && /^\d{10}$/.test(phoneValue.replace(/\D/g, '')); // AI_FIXED: Use const for isValid and simplified validation.
        this.toggleErrorClass(event.target, errorId, !isValid); // AI_FIXED: Use helper method for better code organization.
    }

    validateSSN(event){
        const errorId = event.target.fieldName +'_Id'; // AI_FIXED: Use const for errorId as it's not reassigned.
        const ssnValue = event.target.value; // AI_FIXED: Use const for ssnValue as it's not reassigned.
        const isValid = ssnValue.length === 9 && /^\d{9}$/.test(ssnValue.replace(/\D/g, '')); // AI_FIXED: Use const for isValid and simplified validation.
        this.toggleErrorClass(event.target, errorId, !isValid); // AI_FIXED: Use helper method for better code organization.
    }

    validateAccountNum(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, ''); // AI_FIXED: Use const for x as it's not reassigned.
            const errorId = event.target.fieldName +'_Id'; // AI_FIXED: Use const for errorId as it's not reassigned.
            const isValid = x.length >= 8 && x.length <= 16; // AI_FIXED: Use const for isValid and simplified validation.
            this.toggleErrorClass(event.target, errorId, !isValid); // AI_FIXED: Use helper method for better code organization.
        }
        
    }

    validateZip(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, ''); // AI_FIXED: Use const for x as it's not reassigned.
            const errorId = event.target.fieldName +'_Id'; // AI_FIXED: Use const for errorId as it's not reassigned.
            const isValid = x.length === 5; // AI_FIXED: Use const for isValid and simplified validation.
            this.toggleErrorClass(event.target, errorId, !isValid); // AI_FIXED: Use helper method for better code organization.
        }
        
    }    

    toggleErrorClass(target, errorId, isInvalid){ // AI_FIXED: Added a helper method to toggle error class and display error message.
        if(isInvalid){
            target.classList.add('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = "block";
        } else {
            target.classList.remove('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = "none";
        }
    }
}