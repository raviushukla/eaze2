import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/GuaranteeApprovalApplication.findAccount';
import uploadFiles from '@salesforce/apex/GuaranteeApprovalApplication.uploadFiles';

export default class GuaranteeApprovalApplication extends LightningElement {

    render = true;
    showSpinner = false;
    accountId = '';
    incorporationFile = null; // AI_FIXED: Initialized to null for better type handling
    financialStatement = null; // AI_FIXED: Initialized to null for better type handling
    bankFile = null; // AI_FIXED: Initialized to null for better type handling
    businessLicense = null; // AI_FIXED: Initialized to null for better type handling
    fileDataId = '';
    todayDate = '';
    fileNameBase64Map = {};
    bankFileIndex = 1;
    clientName = '';
    lastMonthBankFile = null; // AI_FIXED: Initialized to null for better type handling
    last2ndMonthBankFile = null; // AI_FIXED: Initialized to null for better type handling
    last3rdMonthBankFile = null; // AI_FIXED: Initialized to null for better type handling

    @api recordId; // AI_FIXED: Added @api annotation to make recordId accessible from parent component

    connectedCallback(){
        this.showSpinner = true;
        this.todayDate = new Date().toLocaleDateString(); // AI_FIXED: Get today's date on component load
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       
        const fields = event.detail.fields;
        let errorPresent = false; // AI_FIXED: Changed to let for better scoping
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                if(target.classList.contains('error')){ // AI_FIXED: More efficient class check
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(!this.incorporationFile || !this.lastMonthBankFile || !this.last2ndMonthBankFile || !this.last3rdMonthBankFile ){ // AI_FIXED: Improved null check
            this.showSpinner = false;
            alert("Please upload all required files."); // AI_FIXED: Improved alert message
            return;
        }
        this.clientName = fields.Principal_Name_1__c;
        this.findAcc(fields.Company_Email__c, fields.Phone__c, fields);
    }

    findAcc(email, mobile, fields){
        findAccount({Email : email})
        .then(result =>{
            if(result){ // AI_FIXED: Simplified null check
                fields.Account__c = result.Id; // AI_FIXED: Accessing the Id property of the result
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.resetFiles(); // AI_FIXED: Call a helper function to reset file inputs
        })
        .catch(error =>{
            this.showSpinner = false;
            console.error('Error finding account:', error); // AI_FIXED: Improved error logging
            this.dispatchEvent(new CustomEvent('error', { detail: error })); // AI_FIXED: Dispatch custom event to handle error in parent component
        });
    }

    formOnLoad(){
        this.showSpinner = false;
    }

    handleSuccess(event){
        const recordId = event.detail.id;
        this.uploadFilesToExternalService(recordId); // AI_FIXED: Extracted the external service call to a separate function
        this.uploadFileAttachments(recordId); // AI_FIXED: Renamed function for clarity and called after external service call
    }

    uploadFilesToExternalService(recordId){ // AI_FIXED: Created a separate function for external service call
        const xhr = new XMLHttpRequest();
        const url = `https://eazeconsulting.my.salesforce-sites.com/services/apexrest/WebServiceUpdateGa?id=${recordId}`; // AI_FIXED: Use template literals for better readability
        xhr.open('POST', url);
        xhr.onload = () => { // AI_FIXED: Use arrow function for better context
            if (xhr.status === 200) {
                const data = JSON.parse(xhr.responseText);
                console.log('External service response:', data); // AI_FIXED: Improved logging
            } else {
                console.error(`Error calling external service: ${xhr.status} ${xhr.statusText}`); // AI_FIXED: Improved error logging
            }
        };
        xhr.onerror = () => { // AI_FIXED: Use arrow function for better context
            console.error('Request error calling external service'); // AI_FIXED: Improved error logging
        };
        xhr.send();
    }

    uploadFileAttachments(recordId){ // AI_FIXED: Renamed function for clarity
        uploadFiles({ recordId, fileNameBase64Map: this.fileNameBase64Map }) // AI_FIXED: Simplified object creation
        .then(result =>{
            this.dispatchEvent(new CustomEvent(
                'thankyouPage', 
                {
                    detail: { data:  this.clientName},
                    bubbles: true,
                    composed: true,
                }
            ));
        })
        .catch(error =>{
            console.error('Error uploading files:', error); // AI_FIXED: Improved error logging
            this.dispatchEvent(new CustomEvent('error', { detail: error })); // AI_FIXED: Dispatch custom event to handle error in parent component
        });
    }

    resetFiles(){ // AI_FIXED: Created a helper function to reset file inputs
        this.incorporationFile = null;
        this.financialStatement = null;
        this.bankFile = null;
        this.businessLicense = null;
        this.lastMonthBankFile = null;
        this.last2ndMonthBankFile = null;
        this.last3rdMonthBankFile = null;
        this.fileNameBase64Map = {};
    }

    handleFileChange(event){
        const file = event.target.files[0];
        if(file && file.type !== 'application/pdf'){ // AI_FIXED: Added null check and strict equality
            alert('Please select a valid PDF file.'); // AI_FIXED: Improved alert message
            return;
        }
        const fileId = event.target.dataset.id; // AI_FIXED: Use dataset for attribute access
        this.readFile(file, fileId); // AI_FIXED: Call a helper function to handle file reading
    }

    readFile(file, fileId) { // AI_FIXED: Created a helper function to handle file reading
        const reader = new FileReader();
        reader.onload = () => {
            const base64 = reader.result.split(',')[1]; // AI_FIXED: Removed unnecessary variable
            let fileName = ''; // AI_FIXED: Declare fileName variable
            switch (fileId) { // AI_FIXED: Use switch statement for better readability
                case 'incorporationFile':
                    fileName = 'Articles of Incorporation ' + file.name;
                    break;
                case 'financialStatement':
                    fileName = 'Year to date profit and loss statement ' + file.name;
                    break;
                case '1stBankFile':
                    fileName = 'Last Month Bank Statement ' + file.name;
                    break;
                case '2ndBankFile':
                    fileName = '2nd Last Month Bank Statement ' + file.name;
                    break;
                case '3rdBankFile':
                    fileName = '3rd Last Month Bank Statement ' + file.name;
                    break;
                case 'businessLicense':
                    fileName = 'Business License ' + file.name;
                    break;
                default:
                    console.warn('Unknown file ID:', fileId); // AI_FIXED: Handle unknown file IDs
                    return;
            }
            this.fileNameBase64Map[fileName] = base64;
        };
        reader.readAsDataURL(file);
    }

    formatPhone(event){
        if(event.target.value){ // AI_FIXED: Simplified null check
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = x ? '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '') : ''; // AI_FIXED: Handle cases where x is null
        }
    }

    formatZip(event){
        if(event.target.value){ // AI_FIXED: Simplified null check
            const x = event.target.value.replace(/\D/g, ''); // AI_FIXED: Removed unnecessary variable
            event.target.value = x.substring(0, 5); // AI_FIXED: Use substring for better performance
        }
    }

    formatSSN(event){
        if(event.target.value){ // AI_FIXED: Simplified null check
            const x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/); // AI_FIXED: Removed unnecessary variable
            event.target.value = x ? x[1] + '-' + x[2] + (x[3] ? '-' + x[3] : '') : ''; // AI_FIXED: Handle cases where x is null
        }
    }

    formatNumber(event){
        if(event.target.value){ // AI_FIXED: Simplified null check
            const x = event.target.value.replace(/\D/g, ''); // AI_FIXED: Removed unnecessary variable
            event.target.value = x;
        }
    }

    formatOnlyText(event){
        if(event.target.value){ // AI_FIXED: Simplified null check
            const x = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,''); // AI_FIXED: Removed unnecessary variable
            event.target.value = x;
        }
    }

    validateField(event, regex, minLength, maxLength){ // AI_FIXED: Created a generic validation function
        const value = event.target.value;
        const errorId = event.target.fieldName + '_Id';
        const isValid = regex.test(value) && (value.length >= minLength && value.length <= maxLength); // AI_FIXED: Combined validation logic
        this.toggleError(event.target, errorId, isValid); // AI_FIXED: Call a helper function to toggle error state
    }

    toggleError(target, errorId, isValid){ // AI_FIXED: Created a helper function to toggle error state
        if(isValid){
            target.classList.remove('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = 'none';
        } else {
            target.classList.add('error');
            this.template.querySelector(`[data-id="${errorId}"]`).style.display = 'block';
        }
    }

    validateEmail(event){
        this.validateField(event, /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/, 1, 255); // AI_FIXED: Call generic validation function
    }

    validateWebsite(event){
        this.validateField(event, /^(?:https?:\/\/)?(?:www\.)[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:\/[^\s]*)?$/, 1, 255); // AI_FIXED: Call generic validation function
    }

    validatePhone(event){
        this.validateField(event, /^\d{10}$/, 10, 10); // AI_FIXED: Call generic validation function
    }

    validateSSN(event){
        this.validateField(event, /^\d{9}$/, 9, 9); // AI_FIXED: Call generic validation function
    }

    validateAccountNum(event){
        this.validateField(event, /^\d{8,16}$/, 8, 16); // AI_FIXED: Call generic validation function
    }

    validateZip(event){
        this.validateField(event, /^\d{5}$/, 5, 5); // AI_FIXED: Call generic validation function
    }
}