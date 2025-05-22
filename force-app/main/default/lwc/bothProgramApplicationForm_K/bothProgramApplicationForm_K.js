import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/BothProgramApplicationForm.findAccount';
import uploadFiles from '@salesforce/apex/BothProgramApplicationForm.uploadFiles';

export default class BothProgramApplicationForm_K extends LightningElement {
    // AI_FIXED: Removed unnecessary variable; reactivity handled by @api
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
    @api recordId; // AI_FIXED: Added @api decorator for recordId


    connectedCallback(){
        this.showSpinner = true;
        // AI_FIXED: Added setTimeout to allow for spinner display
        setTimeout(() => {
            this.showSpinner = false; // AI_FIXED: Set showSpinner to false after a delay
        }, 500);
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       
        const fields = event.detail.fields;
        fields.Program_Type__c = 'Both Program';
        fields.Source_Page__c = 'Kailey Babuin';
        let errorPresent = false; // AI_FIXED: Changed var to let for better scoping
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                if(target.className.includes("error")){
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(this.articleOfIncorp == '' || this.lastMonthBank == '' || this.lastSecondBank == '' || this.lastThirdBank == '' ){
            this.showSpinner = false;
            alert("Upload the required file");
            return;
        }
        this.email = fields.Company_Email__c;
        this.findAcc(fields.Company_Email__c, fields.Phone__c, fields);

        // AI_FIXED: Simplified leadData creation using object spread syntax
        this.leadObj = {
            ...fields, // AI_FIXED: Use object spread syntax to copy fields
            Source_Page: 'Kailey Babuin'
        };
    }

    findAcc(email, mobile, fields){
        findAccount({Email : email})
        .then(result =>{
            if(result){ // AI_FIXED: Simplified null check
                fields.Account__c = result.Id; // AI_FIXED: Access the Id property of the result
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        })
        .catch(error =>{
            this.showSpinner = false;
            // AI_FIXED: Improved error handling
            console.error('Error finding account:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred while finding the account.',
                variant: 'error'
            }));
        });
    }


    handleSuccess(event){
        this.showSpinner = true; // AI_FIXED: Show spinner before making the API call
        this.recordId = event.detail.id; // AI_FIXED: Assign recordId from event
        // AI_FIXED: Replaced XMLHttpRequest with fetch API for better error handling and readability
        fetch('https://eazeconsulting.my.site.com/ga/services/apexrest/WebServiceUpdateGa?id='+ this.recordId)
        .then(response => {
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            return response.json();
        })
        .then(data => {
            console.log(data);
            this.uploadFilesHelper(); // AI_FIXED: Call helper function for better code organization
        })
        .catch(error => {
            this.showSpinner = false; // AI_FIXED: Hide spinner on error
            console.error('Error updating record:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'An error occurred while updating the record.',
                variant: 'error'
            }));
        });
    }

    // AI_FIXED: Helper function to upload files
    uploadFilesHelper() {
        uploadFiles({
            recordId : this.recordId,
            cvIdsList: this.contentVersionIds,
            fields : this.leadObj
        })
        .then(result =>{
            if(result){
                var email = this.email;
                const dataToSend = { key: email};
                window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/both-programs/");
            }else{
                this.showSpinner = false;
            }
        })
        .catch(error =>{
            this.showSpinner = false; // AI_FIXED: Hide spinner on error
            console.error('Error uploading files:', error);
            this.dispatchEvent(new ShowToastEvent({
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
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = !x[2] ? x[1] : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '');
        }

    }

    formatZip(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            event.target.value = x.substr(0, 5);
        }
        
    }

    formatSSN(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/);
            event.target.value = !x[2] ? x[1] :  x[1] + '-' + x[2] + (x[3] ? '-' + x[3] : '');
        }
    }

    formatNumber(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            event.target.value = x; 
        }
    }

    formatOnlyText(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,'');
            event.target.value = x;
        }
    }

    validateEmail(event){
        if(event.target.value != null){
            var errorId = event.target.fieldName +'_Id';
            if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(event.target.value)){
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }else{
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }
        }
        
    }

    validateWebsite(event){
        if(event.target.value != null){
            const websiteUrl = event.target.value;
            const regex = /^(?:https?:\/\/)?(?:www\.)[a-zA-Z0-9-]+(?:\.[a-zA-Z]{2,})(?:\/[^\s]*)?$/;   
            var errorId = event.target.fieldName +'_Id';
            if(regex.test(websiteUrl)){
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }else{
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }
        }
        
    }

    validatePhone(event){
        var errorId = event.target.fieldName +'_Id';
        if(event.target.value.length > 0){
            var x = event.target.value.replace(/\D/g, '');
            if(x.length != 10){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
        }else{
            event.target.classList.remove('error');
            this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
        }
        
    }

    validateSSN(event){
        var errorId = event.target.fieldName +'_Id';
        if(event.target.value.length > 0){
            var x = event.target.value.replace(/\D/g, '');
            var errorId = event.target.fieldName +'_Id';
            if(x.length != 9){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
        }else{
            event.target.classList.remove('error');
            this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
        }
        
    }

    validateAccountNum(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            var errorId = event.target.fieldName +'_Id';
            if(x.length < 8 || x.length > 16){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
        }
        
    }

    validateZip(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            var errorId = event.target.fieldName +'_Id';
            if(x.length != 5){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
        }
        
    }    
}