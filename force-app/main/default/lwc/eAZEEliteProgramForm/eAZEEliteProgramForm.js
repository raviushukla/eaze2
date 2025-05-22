import { LightningElement } from 'lwc';

import findAccount from '@salesforce/apex/EazeEliteProgramForm.findAccount';
import uploadFiles from '@salesforce/apex/EazeEliteProgramForm.uploadFiles';

export default class EAZEEliteProgramForm extends LightningElement {

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
        this.isMarketingLink();
    }
    isMarketingLink(){
        var sourceUrl = window.location.href;
        console.log(sourceUrl);
        var marketingCode = this.urlParam('user');
        if(marketingCode == undefined || marketingCode == ''){
            marketingCode = this.urlParam('amp;user');
        }
        if(marketingCode == 'Kailey'){
            this.sourcePage = 'Kailey Babuin';
        }
        console.log('Marketing Page : '+this.sourcePage);
    }
    urlParam(name){
            var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
            if (results==null){
               return null;
            }
            else{
               return decodeURI(results[1]) || 0;
            }
    }
    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Program_Type__c = 'GA Only';
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
        if(this.lastMonthBank == '' || this.lastSecondBank == '' || this.lastThirdBank == '' ){
            this.showSpinner = false;
            alert("Upload the required file");
            return;
        }
        this.clientName = fields.Name__c;
        fields.Source_Page__c = this.sourcePage;
        this.findAcc(fields.Company_Email__c, fields);
    }

        findAcc(email, fields){
        findAccount({
            businessEmail: email, 
            businessName: fields.Corporate_Business_Name__c,
            phone: fields.Phone1__c, 
          //  principalPhone: fields.Phone2__c, 
            principalName1: fields.Name__c, 
            clientDBA: fields.DBA__c
        })
        .then(result => {
            console.log('result', result);
            if(result != null && result !== '') {
                fields.Account__c = result;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }).catch(error => {
                console.error('Error finding account:', error);
                // Show user-friendly error message
                alert('Error submitting form: ' + (error.body?.message || 'Unknown error'));
                this.showSpinner = false;
            })
         .finally(() => {
             this.showSpinner = false; // Ensure spinner is hidden after processing
         });
    }

    formOnLoad(){
        this.showSpinner = false;
    }

    handleError(event){
        console.log('handle error is calling : ');
        console.error('handle error is calling 2: ', JSON.stringify(event));
    }

    handleSuccess(event){

        console.log('handle succ is calling : ');
       // this.showSpinner = false;
        const recordId = event.detail.id;
        
        //************************** */
        console.log('Content Version IDs:', this.contentVersionIds);
        console.log('Uploading files to record:', recordId);
        uploadFiles({
            
            recordId : recordId,
            
            cvIdsList: this.contentVersionIds
            
        })
        .then(result =>{
            
            var cName = this.clientName;
            const dataToSend = { key: cName};
            window.parent.postMessage(dataToSend, "https://www.eazeconsulting.com/eaze-elite-application/");
           // window.parent.postMessage(dataToSend, "*");
           // Redirect to the desired URL after submission
            window.location.href = "https://www.eazeconsulting.com/eaze-elite-application/";
        }).catch(error =>{
            console.log(error);
        }).finally(() => {
        this.showSpinner = false; // Ensure spinner is hidden after processing
       });
    }

    get acceptedFormats() {
        return ['.pdf'];
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