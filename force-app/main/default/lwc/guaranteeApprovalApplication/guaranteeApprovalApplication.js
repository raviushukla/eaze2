import { LightningElement } from 'lwc';

import findAccount from '@salesforce/apex/GuaranteeApprovalApplication.findAccount';
import uploadFiles from '@salesforce/apex/GuaranteeApprovalApplication.uploadFiles';

export default class GuaranteeApprovalApplication extends LightningElement {

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
    lastMonthBankFile = '';
    last2ndMonthBankFile = '';
    last3rdMonthBankFile = '';

    connectedCallback(){
        this.showSpinner = true;
    }

    handleSubmit(event) {
        this.showSpinner = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        var errorPresent = false;
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(target => {
                console.log('target.className.includes("error")',target.className.includes("error"));
                if(target.className.includes("error")){
                    console.log("Error present");
                    this.showSpinner = false;
                    errorPresent = true;
                }

            });
        }
        if(errorPresent){
            return;
        }
        if(this.incorporationFile == '' ||  this.lastMonthBankFile == '' ||  this.last2ndMonthBankFile == '' ||  this.last3rdMonthBankFile == '' ){
            this.showSpinner = false;
            alert("Upload the required file");
            return;
        }
        this.clientName = fields.Principal_Name_1__c;
        this.findAcc(fields.Company_Email__c, fields.Phone__c, fields);
    }

    findAcc(email, mobile, fields){
        findAccount({Email : email})
        .then(result =>{
            console.log('result',result);
            if(result != null || result != ''){
                fields.Account__c = result;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
            this.incorporationFile = '';  
            this.financialStatement = '';
            this.bankFile = ''; 
            this.businessLicense = '' ;
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
        var url = 'https://eazeconsulting.my.salesforce-sites.com/services/apexrest/WebServiceUpdateGa?id='+recordId;
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
            /*incorporationFile : this.incorporationFile,
            financialStatement : this.financialStatement,
            bankFile : this.bankFile,
            businessLicense : this.businessLicense,
            incorporationFileBase64 : this.incorporationFileBase64,
            financialStatementBase64 : this.financialStatementBase64,
            bankFileBase64 : this.bankFileBase64,
            businessLicenseBase64 : this.businessLicenseBase64,
            recordId : recordId*/
            recordId : recordId,
            fileNameBase64Map: this.fileNameBase64Map
            
        })
        .then(result =>{
            this.dispatchEvent(new CustomEvent(
                'thankyouPage', 
                {
                    detail: { data:  this.clientName},
                    bubbles: true,
                    composed: true,
                }
            ));
            //window.location =  'https://www.eazeconsulting.com/guaranteed-approval-thank-you/?clnm='+this.clientName;
        }).catch(error =>{
            console.log(error);
        });
    }

    uploadDocuments(){
        
    }

    handleFileChange(event){
        const file = event.target.files[0];
        if(file.type != 'application/pdf'){
            alert('Please Select a Valid PDF File');
            return;
        }
        if(event.target.getAttribute("data-id") == "incorporationFile"){
            this.fileDataId = event.target.getAttribute("data-id");
            this.incorporationFile = file.name;
            this.fileReader(file);
        }else if(event.target.getAttribute("data-id") == "financialStatement"){
            this.fileDataId = event.target.getAttribute("data-id");
            this.financialStatement = file.name;
            this.fileReader(file);
        }else if(event.target.getAttribute("data-id") == "1stBankFile"){
            this.fileDataId = event.target.getAttribute("data-id");
            this.lastMonthBankFile = file.name;
            this.fileReader(file);
            /*
            const multiFile = event.target.files;
            for(var i=0; i< multiFile.length; i++){
                this.bankFile += this.bankFile == '' ? multiFile[i].name: ', '+multiFile[i].name;
                this.fileReader(multiFile[i]);
            }*/
        }else if(event.target.getAttribute("data-id") == "2ndBankFile"){
            this.fileDataId = event.target.getAttribute("data-id");
            this.last2ndMonthBankFile = file.name;
            this.fileReader(file);
        }else if(event.target.getAttribute("data-id") == "3rdBankFile"){
            this.fileDataId = event.target.getAttribute("data-id");
            this.last3rdMonthBankFile = file.name;
            this.fileReader(file);
        }else if(event.target.getAttribute("data-id") == "businessLicense"){
            this.fileDataId = event.target.getAttribute("data-id");
            this.businessLicense = file.name;
            this.fileReader(file);
        }
    }

    fileReader(file) {
        // create a FileReader object 
        var reader = new FileReader();
        reader.onload = () => {
            var base64 = reader.result.split(',')[1]
            if(this.fileDataId == "incorporationFile"){
                //this.incorporationFileBase64 = base64;
                this.fileNameBase64Map['Articles of Incorporation '+file.name] = base64;
            }else if(this.fileDataId == "financialStatement"){
                //this.financialStatementBase64 = base64;
                this.fileNameBase64Map['Year to date profit and loss statement '+file.name] = base64;
            }else if(this.fileDataId == "1stBankFile"){
                this.fileNameBase64Map['Last Month Bank Statement  '+file.name] = base64;
                //this.fileNameBase64Map['Bank Statement '+this.bankFileIndex+' '+file.name] = base64;
                //this.bankFileIndex++;
            }else if(this.fileDataId == "2ndBankFile"){
                this.fileNameBase64Map['2nd Last Month Bank Statement  '+file.name] = base64;
            }else if(this.fileDataId == "3rdBankFile"){
                this.fileNameBase64Map['3rd Last Month Bank Statement  '+file.name] = base64;
            }else if(this.fileDataId == "businessLicense"){
                this.fileNameBase64Map['Business License '+file.name] = base64;
            }
        }; 
        reader.readAsDataURL(file);
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
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            var errorId = event.target.fieldName +'_Id';
            if(x.length != 10){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
        }
        
    }

    validateSSN(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            var errorId = event.target.fieldName +'_Id';
            if(x.length != 9){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
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