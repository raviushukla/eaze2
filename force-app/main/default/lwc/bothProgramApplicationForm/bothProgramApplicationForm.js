import { LightningElement } from 'lwc';

import findAccount from '@salesforce/apex/BothProgramApplicationForm.findAccount';
import uploadFiles from '@salesforce/apex/BothProgramApplicationForm.uploadFiles';

export default class BothProgramApplicationForm extends LightningElement {

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
        this.isMarketingLink();
    }
    isMarketingLink(){
        var sourceUrl = window.location.href;
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
        fields.Program_Type__c = 'Both Program';
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
        console.log('Fields : '+ JSON.stringify(fields));
        this.email = fields.Company_Email__c;
        fields.Source_Page__c = this.sourcePage;
        this.findAcc(fields.Company_Email__c, fields.Phone__c, fields);

        var leadData = {};
        leadData.Associate = fields.Associate__c;
        leadData.Corporate_Business_Name = fields.Corporate_Business_Name__c;
        leadData.Company_Website = fields.Company_Website__c;
        leadData.Address = fields.Address__c;
        leadData.City = fields.City__c;
        leadData.State = fields.State__c;
        leadData.Zip = fields.Zip__c;
        leadData.Phone = fields.Phone__c;
        leadData.Company_Email = fields.Company_Email__c;
        leadData.Principal_Name_1 = fields.Principal_Name_1__c;
        leadData.Been_In_Business_Years = fields.Been_In_Business_Years__c;
        leadData.Number_of_Sales_Agent = fields.Number_of_Sales_Agent__c;
        leadData.Referred_By = fields.Referred_By__c;
        leadData.Accounting_Associate = fields.Accounting_Associate__c;
        leadData.Accounting_Associate_Contact_Email = fields.Accounting_Associate_Contact_Email__c;
        leadData.Total_Sales_For_2023 = fields.Total_Sales_For_2023__c;
        leadData.Business_Incorporation_State = fields.Business_Incorporation_State__c;
        leadData.Source_Page = this.sourcePage;

        this.leadObj = leadData;
        console.log('Lead Object : ' + this.leadObj);
    }

    findAcc(email, mobile, fields){
        findAccount({Email : email})
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
        }).catch(error =>{
            alert('Please fill the form again.')
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