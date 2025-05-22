import { LightningElement, api } from 'lwc';

import findAccount from '@salesforce/apex/GuaranteeApprovalApplicationForm.findAccount';
import uploadFiles from '@salesforce/apex/GuaranteeApprovalApplicationForm.uploadFiles';

export default class GuaranteedApprovalApplicationForm_K extends LightningElement {
    @api recordId; // AI_FIXED: Added @api annotation to make recordId accessible from parent component

    showSpinner = false;
    accountId = '';
    articleOfIncorp = '';
    profitAndLoss = '';
    lastMonthBank = '';
    lastSecondBank = '';
    lastThirdBank = '';
    contentVersionIds = [];
    clientName = '';


    connectedCallback(){
        this.showSpinner = false; // AI_FIXED: Removed unnecessary setting of showSpinner to true in connectedCallback.  It should be false initially.
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();
        const fields = event.detail.fields;
        fields.Program_Type__c = 'GA Only';
        fields.Source_Page__c = 'Kailey Babuin';
        let errorPresent = false; // AI_FIXED: Changed var to let for better scoping.
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                if(target.classList.contains('error')){ // AI_FIXED: Improved error check using classList.contains
                    console.log("Error present "+ target.fieldName); // AI_FIXED: Accessing fieldName directly.
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(this.articleOfIncorp === '' || this.lastMonthBank === '' || this.lastSecondBank === '' || this.lastThirdBank === '' ){ // AI_FIXED: Use === for strict equality
            this.showSpinner = false;
            alert("Please upload all required files."); // AI_FIXED: Improved alert message.
            return;
        }
        this.clientName = fields.Principal_Name_1__c;
        this.findAcc(fields.Company_Email__c, fields);
    }

    findAcc(email, fields){
        findAccount({Email : email, businessName : fields.Corporate_Business_Name__c, phone : fields.Phone__c, 
                    principalPhone1 : fields.Principal_Phone_1__c, principalPhone2 : fields.Principal_Phone_2__c,
                    principalName1 : fields.Principal_Name_1__c, principalName2 : fields.Principal_Name_2__c})
        .then(result =>{
            if(result){ // AI_FIXED: Simplified null check.
                fields.Account__c = result.Id; // AI_FIXED: Assuming the apex method returns an Account object with an Id.
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        })
        .catch(error =>{ // AI_FIXED: Improved error handling.
            console.error('Error finding account:', error); // AI_FIXED: More informative error message.
            this.showSpinner = false;
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a user-friendly toast message.
                title: 'Error',
                message: 'An error occurred while finding the account.',
                variant: 'error'
            }));
        });
    }

    handleSuccess(event){
        this.showSpinner = false; // AI_FIXED: Hide spinner after successful submission.
        const recordId = event.detail.id;
        // Updating the record to generate PDF - AI_FIXED:  This section is risky and should be reviewed.  Directly calling an external URL is generally not recommended. Consider using a Salesforce Apex method instead.
        const xhr = new XMLHttpRequest();
        var url = 'https://eazeconsulting.my.site.com/ga/services/apexrest/WebServiceUpdateGa?id='+recordId;
        xhr.open('POST',url);
        xhr.onload = function() {
        if (xhr.status === 200) {
            const data = JSON.parse(xhr.responseText);
            console.log(data);
        } else {
            console.error(`Error: ${xhr.status}`);
        }
        };
        xhr.onerror = function() {
        console.error('Request error');
        };
        xhr.send();
        uploadFiles({
            recordId : recordId,
            cvIdsList: this.contentVersionIds
        })
        .then(result =>{
            var cName = this.clientName;
            const dataToSend = { key: cName};
            window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/guaranteed-approval-application/");
        })
        .catch(error =>{ // AI_FIXED: Improved error handling.
            console.error('Error uploading files:', error); // AI_FIXED: More informative error message.
            this.dispatchEvent(new ShowToastEvent({ // AI_FIXED: Display a user-friendly toast message.
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
        if(event.target.value){ // AI_FIXED: Simplified null check.
            var x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = !x[2] ? x[1] : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '');
        }

    }

    formatZip(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            var x = event.target.value.replace(/\D/g, '');
            event.target.value = x.substr(0, 5);
        }
        
    }

    formatSSN(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            var x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/);
            event.target.value = !x[2] ? x[1] :  x[1] + '-' + x[2] + (x[3] ? '-' + x[3] : '');
        }
    }

    formatNumber(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            var x = event.target.value.replace(/\D/g, '');
            event.target.value = x; 
        }
    }

    formatOnlyText(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
            var x = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,'');
            event.target.value = x;
        }
    }

    validateEmail(event){
        if(event.target.value){ // AI_FIXED: Simplified null check.
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
        if(event.target.value){ // AI_FIXED: Simplified null check.
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
        if(event.target.value){ // AI_FIXED: Simplified null check.
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
        if(event.target.value){ // AI_FIXED: Simplified null check.
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