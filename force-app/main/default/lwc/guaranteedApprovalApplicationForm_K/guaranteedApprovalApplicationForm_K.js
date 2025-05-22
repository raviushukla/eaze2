import { LightningElement } from 'lwc';

import findAccount from '@salesforce/apex/GuaranteeApprovalApplicationForm.findAccount';
import uploadFiles from '@salesforce/apex/GuaranteeApprovalApplicationForm.uploadFiles';

export default class GuaranteedApprovalApplicationForm_K extends LightningElement {
    
    /*
        * I have set the Id of all the span tag(Invalid input display) as the field-name + '_Id' 
    */
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


    connectedCallback(){
        this.showSpinner = true;
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Program_Type__c = 'GA Only';
        fields.Source_Page__c = 'Kailey Babuin';
        var errorPresent = false;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                console.log('target.className.includes("error")',target.className.includes("error"));
                if(target.className.includes("error")){
                    console.log("Error present "+ target.getAttribute('field-name'));
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
        this.clientName = fields.Principal_Name_1__c;
        this.findAcc(fields.Company_Email__c, fields);
    }

    findAcc(email, fields){
        findAccount({Email : email, businessName : fields.Corporate_Business_Name__c, phone : fields.Phone__c, 
                    principalPhone1 : fields.Principal_Phone_1__c, principalPhone2 : fields.Principal_Phone_2__c,
                    principalName1 : fields.Principal_Name_1__c, principalName2 : fields.Principal_Name_2__c})
        .then(result =>{
            console.log('result',result);
            if(result != null || result != ''){
                fields.Account__c = result;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }).catch(error =>{
            console.log(error);
            this.showSpinner = false;
        });
    }

    formOnLoad(){
        this.showSpinner = false;
    }

    handleSuccess(event){
        const recordId = event.detail.id;
        // Updating the record to generate PDF
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
        //************************** */
        uploadFiles({
            recordId : recordId,
            cvIdsList: this.contentVersionIds
        })
        .then(result =>{
            var cName = this.clientName;
            const dataToSend = { key: cName};
            window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/guaranteed-approval-application/");
        }).catch(error =>{
            console.log(error);
        });
    }

    get acceptedFormats() {
        return ['.pdf'];
    }

    handleUploadIncorp(event) {
        // Get the list of uploaded files
        const uploadedFile = event.detail.files;
        this.articleOfIncorp = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadProfitLoss(event) {
        // Get the list of uploaded files
        const uploadedFile = event.detail.files;
        this.profitAndLoss = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastMonthBank(event) {
        // Get the list of uploaded files
        const uploadedFile = event.detail.files;
        this.lastMonthBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastSecondBank(event) {
        // Get the list of uploaded files
        const uploadedFile = event.detail.files;
        this.lastSecondBank = uploadedFile[0].name;
        this.contentVersionIds.push(uploadedFile[0].contentVersionId);
    }

    handleUploadLastThirdBank(event) {
        // Get the list of uploaded files
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