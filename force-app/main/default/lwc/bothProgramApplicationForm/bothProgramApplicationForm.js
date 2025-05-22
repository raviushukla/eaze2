import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/BothProgramApplicationForm.findAccount';
import uploadFiles from '@salesforce/apex/BothProgramApplicationForm.uploadFiles';

export default class BothProgramApplicationForm extends LightningElement {

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
    email = '';
    contentVersionIds = [];
    articleOfIncorp = '';
    profitAndLoss = '';
    lastMonthBank = '';
    lastSecondBank = '';
    lastThirdBank = '';
    leadObj = {};
    sourcePage = '';


    connectedCallback(){
        this.showSpinner = true;
        this.getSourcePage(); // AI_FIXED: Renamed method for clarity and better naming convention
    }

    getSourcePage(){ // AI_FIXED: Renamed method for clarity and better naming convention
        const sourceUrl = window.location.href;
        const marketingCode = this.getUrlParam('user') || this.getUrlParam('amp;user'); // AI_FIXED: Simplified marketing code retrieval
        if(marketingCode === 'Kailey'){
            this.sourcePage = 'Kailey Babuin';
        }
        console.log('Marketing Page : '+this.sourcePage);
        this.showSpinner = false; // AI_FIXED: Set showSpinner to false after completing the operation.
    }

    getUrlParam(name){ // AI_FIXED: Renamed method for clarity and better naming convention
        const results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        return results ? decodeURI(results[1]) : null; // AI_FIXED: Simplified conditional return using ternary operator
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       
        const fields = event.detail.fields;
        fields.Program_Type__c = 'Both Program';
        let errorPresent = false; // AI_FIXED: Changed to let for better scoping
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                if(target.classList.contains('error')){ // AI_FIXED: Improved class check using classList.contains
                    console.log("Error present "+ target.fieldName); // AI_FIXED: Accessing fieldName directly
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(this.articleOfIncorp === '' || this.lastMonthBank === '' || this.lastSecondBank === '' || this.lastThirdBank === '' ){ // AI_FIXED: Using strict equality for better comparison
            this.showSpinner = false;
            alert("Upload the required file");
            return;
        }
        console.log('Fields : '+ JSON.stringify(fields));
        this.email = fields.Company_Email__c;
        fields.Source_Page__c = this.sourcePage;
        this.findAccountAndSubmit(fields); // AI_FIXED: Renamed method for better naming convention

    }

    findAccountAndSubmit(fields){ // AI_FIXED: Renamed method for better naming convention
        findAccount({Email : this.email}) // AI_FIXED: Using this.email directly
        .then(result =>{
            console.log('result',result);
            if(result){ // AI_FIXED: Simplified condition
                fields.Account__c = result.Id; // AI_FIXED: Accessing the Id property of the result
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        })
        .catch(error =>{
            console.error('Error finding account:', error); // AI_FIXED: Improved error handling and logging
            this.showSpinner = false;
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a toast message to the user
                title: 'Error',
                message: 'An error occurred while finding the account.',
                variant: 'error'
            }));
        });
    }

    handleSuccess(event){
        this.showSpinner = false; // AI_FIXED: Set showSpinner to false after successful submission
        const recordId = event.detail.id;
        this.updateRecordAndSendEmail(recordId); // AI_FIXED: Extracted the logic into a separate function for better readability and maintainability.
    }

    updateRecordAndSendEmail(recordId){ // AI_FIXED: Created a new function to handle the update and email sending logic.
        // Updating the record to generate PDF
        const xhr = new XMLHttpRequest();
        const url = `https://eazeconsulting.my.site.com/ga/services/apexrest/WebServiceUpdateGa?id=${recordId}`; // AI_FIXED: Using template literals for better string formatting
        xhr.open('POST', url);
        xhr.onload = () => { // AI_FIXED: Using arrow function for better readability
            if (xhr.status === 200) {
                const data = JSON.parse(xhr.responseText);
                console.log(data);
            } else {
                console.error(`Error: ${xhr.status}`);
                this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a toast message to the user
                    title: 'Error',
                    message: 'An error occurred while updating the record.',
                    variant: 'error'
                }));
            }
        };
        xhr.onerror = () => { // AI_FIXED: Using arrow function for better readability
            console.error('Request error');
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a toast message to the user
                title: 'Error',
                message: 'An error occurred while communicating with the server.',
                variant: 'error'
            }));
        };
        xhr.send();

        uploadFiles({
            recordId : recordId,
            cvIdsList: this.contentVersionIds,
            fields : this.leadObj
        })
        .then(result =>{
            if(result){
                const dataToSend = { key: this.email }; // AI_FIXED: Using this.email directly
                window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/both-programs/");
            } else {
                this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a toast message to the user
                    title: 'Error',
                    message: 'An error occurred while uploading files.',
                    variant: 'error'
                }));
            }
        })
        .catch(error =>{
            console.error('Error uploading files:', error); // AI_FIXED: Improved error handling and logging
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a toast message to the user
                title: 'Error',
                message: 'An error occurred while uploading files.',
                variant: 'error'
            }));
        });
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
        if(event.target.value){ // AI_FIXED: Simplified condition
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = x ? `(${x[1]}) ${x[2]}${x[3] ? `-${x[3]}` : ''}` : ''; // AI_FIXED: Simplified conditional assignment using ternary operator
        }

    }

    formatZip(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            const x = event.target.value.replace(/\D/g, '');
            event.target.value = x.substring(0, 5); // AI_FIXED: Using substring for better readability
        }
    }

    formatSSN(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/);
            event.target.value = x ? `${x[1]}-${x[2]}${x[3] ? `-${x[3]}` : ''}` : ''; // AI_FIXED: Simplified conditional assignment using ternary operator
        }
    }

    formatNumber(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            event.target.value = event.target.value.replace(/\D/g, ''); // AI_FIXED: Simplified assignment
        }
    }

    formatOnlyText(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            event.target.value = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,''); // AI_FIXED: Simplified assignment
        }
    }

    validateEmail(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            const errorId = `${event.target.fieldName}_Id`; // AI_FIXED: Using template literals for better string formatting
            const isValid = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(event.target.value); // AI_FIXED: Stored the result of the regex test in a variable
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Extracted the common logic into a separate function
        }
    }

    validateWebsite(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            const websiteUrl = event.target.value;
            const regex = /^(?:https?:\/\/)?(?:www\.)[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:\/[^\s]*)?$/;   
            const errorId = `${event.target.fieldName}_Id`; // AI_FIXED: Using template literals for better string formatting
            const isValid = regex.test(websiteUrl); // AI_FIXED: Stored the result of the regex test in a variable
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Extracted the common logic into a separate function
        }
    }

    validatePhone(event){
        const errorId = `${event.target.fieldName}_Id`; // AI_FIXED: Using template literals for better string formatting
        const phoneValue = event.target.value.replace(/\D/g, '');
        const isValid = phoneValue.length === 10; // AI_FIXED: Simplified condition
        this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Extracted the common logic into a separate function
    }

    validateSSN(event){
        const errorId = `${event.target.fieldName}_Id`; // AI_FIXED: Using template literals for better string formatting
        const ssnValue = event.target.value.replace(/\D/g, '');
        const isValid = ssnValue.length === 9; // AI_FIXED: Simplified condition
        this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Extracted the common logic into a separate function
    }

    validateAccountNum(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            const accountNumValue = event.target.value.replace(/\D/g, '');
            const errorId = `${event.target.fieldName}_Id`; // AI_FIXED: Using template literals for better string formatting
            const isValid = accountNumValue.length >= 8 && accountNumValue.length <= 16; // AI_FIXED: Simplified condition
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Extracted the common logic into a separate function
        }
    }

    validateZip(event){
        if(event.target.value){ // AI_FIXED: Simplified condition
            const zipValue = event.target.value.replace(/\D/g, '');
            const errorId = `${event.target.fieldName}_Id`; // AI_FIXED: Using template literals for better string formatting
            const isValid = zipValue.length === 5; // AI_FIXED: Simplified condition
            this.toggleErrorClass(event, errorId, isValid); // AI_FIXED: Extracted the common logic into a separate function
        }
    }

    toggleErrorClass(event, errorId, isValid){ // AI_FIXED: Created a new function to handle the common logic for toggling error classes
        if(isValid){
            event.target.classList.remove('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = "none"; // AI_FIXED: Using template literals for better string formatting
        } else {
            event.target.classList.add('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = "block"; // AI_FIXED: Using template literals for better string formatting
        }
    }
}