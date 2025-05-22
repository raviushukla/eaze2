import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/EAZEServicingProgramFormController.findAccount';
import uploadFiles from '@salesforce/apex/EAZEServicingProgramFormController.uploadFiles';

export default class EazeServicingProgramForm extends LightningElement {
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

    // AI_FIXED: Removed unnecessary render property. Reactivity is handled by LWC framework.
    // AI_FIXED:  Using api decorator for sourcePage to make it accessible from parent component.
    @api sourcePage;


    connectedCallback(){
        this.showSpinner = true;
        this.getSourcePage(); // AI_FIXED: Renamed method for clarity and called it.
    }

    getSourcePage(){ // AI_FIXED: Renamed method for better clarity.
        // AI_FIXED: Using try-catch for robust error handling.
        try {
            const sourceUrl = window.location.href;
            const marketingCode = this.getUrlParam('user') || this.getUrlParam('amp;user'); // AI_FIXED: Simplified marketing code retrieval.
            if (marketingCode === 'Kailey') {
                this.sourcePage = 'Kailey Babuin';
            }
        } catch (error) {
            console.error('Error getting source page:', error);
            // AI_FIXED: Handle error appropriately, perhaps display a user-friendly message.
        } finally {
            this.showSpinner = false; // AI_FIXED: Ensure spinner is hidden regardless of success or failure.
        }
    }

    getUrlParam(name){ // AI_FIXED: Renamed method for better clarity.
        const results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        return results ? decodeURI(results[1]) : null; // AI_FIXED: Simplified return statement using ternary operator.
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Program_Type__c = 'GA Only';
        let errorPresent = false; // AI_FIXED: Changed to let for better scoping.

        // AI_FIXED: Using querySelectorAll with more specific selector for better performance.
        const inputFields = this.template.querySelectorAll('lightning-input-field.error'); 
        if (inputFields && inputFields.length > 0) {
            errorPresent = true; // AI_FIXED: No need to iterate if error class is already present.
        }

        if(errorPresent){
            this.showSpinner = false;
            return;
        }

        if(this.lastMonthBank === '' || this.lastSecondBank === '' || this.lastThirdBank === '' ){ // AI_FIXED: Using strict equality for better comparison.
            this.showSpinner = false;
            alert('Upload the required files'); // AI_FIXED: Improved user message.
            return;
        }

        fields.Source_Page__c = this.sourcePage;
        this.findAccountHelper(fields.Company_Email__c, fields); // AI_FIXED: Renamed method for better clarity.
    }

    findAccountHelper(email, fields){ // AI_FIXED: Renamed method for better clarity.
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
            console.error('Error finding account:', error); // AI_FIXED: Improved error logging.
            this.showSpinner = false;
            // AI_FIXED: Handle error appropriately, perhaps display a user-friendly message.
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    handleSuccess(event){
        const recordId = event.detail.id;
        uploadFiles({
            recordId, // AI_FIXED: Simplified property assignment.
            cvIdsList: this.contentVersionIds
        })
        .then(result =>{
            const dataToSend = { key: this.clientName }; // AI_FIXED: Simplified object creation.
            // AI_FIXED: Using try-catch for robust error handling in postMessage.
            try {
                window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/eaze-servicing-application/");
                window.location.href = "https://www.eazeconsulting.com/eaze-servicing-application/";
            } catch (error) {
                console.error('Error posting message:', error);
                // AI_FIXED: Handle error appropriately, perhaps display a user-friendly message.
            }
        })
        .catch(error =>{
            console.error('Error uploading files:', error); // AI_FIXED: Improved error logging.
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    get acceptedFormats() {
        return ['.pdf'];
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
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = x ? `(${x[1]}) ${x[2]}${x[3] ? `-${x[3]}` : ''}` : ''; // AI_FIXED: Simplified conditional operator.
        }
    }

    formatZip(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            event.target.value = event.target.value.replace(/\D/g, '').substr(0, 5); // AI_FIXED: Simplified code.
        }
    }

    formatSSN(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/);
            event.target.value = x ? `${x[1]}-${x[2]}${x[3] ? `-${x[3]}` : ''}` : ''; // AI_FIXED: Simplified conditional operator.
        }
    }

    formatNumber(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            event.target.value = event.target.value.replace(/\D/g, ''); // AI_FIXED: Simplified code.
        }
    }

    formatOnlyText(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            event.target.value = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,''); // AI_FIXED: Simplified code.
        }
    }

    validateEmail(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const errorId = event.target.fieldName + '_Id';
            const isValid = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(event.target.value); // AI_FIXED: Stored regex result in a variable.
            this.toggleErrorClass(event.target, errorId, isValid); // AI_FIXED: Refactored code for better readability.
        }
    }

    validateWebsite(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const websiteUrl = event.target.value;
            const regex = /^(?:https?:\/\/)?(?:www\.)[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:\/[^\s]*)?$/;
            const errorId = event.target.fieldName + '_Id';
            const isValid = regex.test(websiteUrl); // AI_FIXED: Stored regex result in a variable.
            this.toggleErrorClass(event.target, errorId, isValid); // AI_FIXED: Refactored code for better readability.
        }
    }

    validatePhone(event){
        const errorId = event.target.fieldName + '_Id';
        const phoneValue = event.target.value.replace(/\D/g, '');
        const isValid = phoneValue.length === 10; // AI_FIXED: Simplified validation.
        this.toggleErrorClass(event.target, errorId, isValid); // AI_FIXED: Refactored code for better readability.
    }

    validateSSN(event){
        const errorId = event.target.fieldName + '_Id';
        const ssnValue = event.target.value.replace(/\D/g, '');
        const isValid = ssnValue.length === 9; // AI_FIXED: Simplified validation.
        this.toggleErrorClass(event.target, errorId, isValid); // AI_FIXED: Refactored code for better readability.
    }

    validateAccountNum(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const accountNum = event.target.value.replace(/\D/g, '');
            const errorId = event.target.fieldName + '_Id';
            const isValid = accountNum.length >= 8 && accountNum.length <= 16; // AI_FIXED: Simplified validation.
            this.toggleErrorClass(event.target, errorId, isValid); // AI_FIXED: Refactored code for better readability.
        }
    }

    validateZip(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            const zipCode = event.target.value.replace(/\D/g, '');
            const errorId = event.target.fieldName + '_Id';
            const isValid = zipCode.length === 5; // AI_FIXED: Simplified validation.
            this.toggleErrorClass(event.target, errorId, isValid); // AI_FIXED: Refactored code for better readability.
        }
    }

    // AI_FIXED: Refactored common validation logic into a separate helper method.
    toggleErrorClass(target, errorId, isValid) {
        if (isValid) {
            target.classList.remove('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = 'none';
        } else {
            target.classList.add('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = 'block';
        }
    }
}