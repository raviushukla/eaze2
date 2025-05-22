import { LightningElement, track } from 'lwc';
import uploadFiles from '@salesforce/apex/InstantApprovalDocumentUpload.uploadFiles';
import getAcc from '@salesforce/apex/InstantApprovalDocumentUpload.getAcc';
import applicationLink   from "@salesforce/label/c.Instant_Approval_Application";

export default class InstantApprovalDocumentUpload extends LightningElement {

    accId = '';
    incorporation = '';
    profitLoss = '';
    balanceSheet = '';
    businessTaxReturn = '';
    @track ownerTaxReturn = [];
    termCondition = '';
    marketingPrint = '';
    marketingScript = '';
    writtenPolicies = '';
    onboardingScript = '';
    welcomeCallScript = '';
    contentPlatform = '';
    applicationForm = '';
    showApplication = true;
    spinner = true;

    label = {
    applicationLink,
    };


    connectedCallback() {
        this.spinner = false;
        const urlParams = new URLSearchParams(window.location.search);
        var clientCode = urlParams.get('clientCode');
        getAcc({ clientCode : clientCode })
		.then(result => {
			if(result.accId != null){
                this.accId = result.accId;
            }
            if(result.contentVerList != null){
                this.existingDocs(result.contentVerList);
            }
		})
		.catch(error => {

		})
    }

    handleUploadFinished(event) {

        const contentVersionIds = [];
        var fileCode = '';
        var uploadButtonId = event.target.dataset.targetId;
        const uploadedFiles = event.detail.files;
        uploadedFiles.forEach((files) => {
            contentVersionIds.push(files.contentVersionId);
            if(uploadButtonId == 'Incorp'){
                this.incorporation = files.name;
                fileCode = '1';
            }else if(uploadButtonId == 'ProfitLoss'){
                this.profitLoss = files.name;
                fileCode = '2';
            }else if(uploadButtonId == 'BalanceSheet'){
                this.balanceSheet = files.name;
                fileCode = '3';
            }else if(uploadButtonId == 'BusinessTaxReturn'){
                this.businessTaxReturn = files.name;
                fileCode = '4';
            }else if(uploadButtonId == 'OwnerTaxReturn'){
                let fileData = {};
                fileData.Title = files.name
                this.ownerTaxReturn.push(fileData);
                fileCode = '5';
            }else if(uploadButtonId == 'TermCondition'){
                this.termCondition = files.name;
                fileCode = '6';
            }else if(uploadButtonId == 'MarketingPrint'){
                this.marketingPrint = files.name;
                fileCode = '7';
            }else if(uploadButtonId == 'MarketingScript'){
                this.marketingScript = files.name;
                fileCode = '8';
            }else if(uploadButtonId == 'WrittenPolicies'){
                this.writtenPolicies = files.name;
                fileCode = '9';
            }else if(uploadButtonId == 'OnboardingScript'){
                this.onboardingScript = files.name;
                fileCode = '10';
            }else if(uploadButtonId == 'WelcomeCallScript'){
                this.welcomeCallScript = files.name;
                fileCode = '11';
            }else if(uploadButtonId == 'ContentPlatform'){
                this.contentPlatform = files.name;
                fileCode = '12';
            }else if(uploadButtonId == 'applicationForm'){
                this.applicationForm = files.name;
                fileCode = '13';
            }
        });
        //console.log('this.ownerTaxReturn ',this.ownerTaxReturn);
        this.attachFileAcc(contentVersionIds, fileCode);
        if(this.incorporation !== '' && this.profitLoss !== '' && this.balanceSheet !== '' && this.businessTaxReturn !== '' && 
        this.ownerTaxReturn.length > 0 && this.termCondition !== '' && this.marketingPrint !== '' && this.marketingScript !== '' && 
        this.writtenPolicies !== '' && this.onboardingScript !== '' && this.welcomeCallScript !== '' && this.contentPlatform !== '' ){
            this.showApplication = true;
            this.showApplicationSection();
        }
        
    }

    attachFileAcc(contentVersionIds, fileCode){
        uploadFiles({ recordId: this.accId,cvIds : contentVersionIds , fileCode : fileCode })
		.then(result => {
			
		})
		.catch(error => {
            console.log(error);
		})
    }

    existingDocs(docList){
        const fileByCode = {};
        docList.forEach(obj => {
            const code = obj.Oasis_Instant_Approval_Doc_Code__c;
            if (!(code in fileByCode)) {
                fileByCode[code] = [];
            }
            fileByCode[code].push(obj);
        });
        console.log(fileByCode);
        const latestFileOnly = {};
        for (const code in fileByCode) {
            //console.log(code);  
            const filesWithSameCode = fileByCode[code];
            const latestFile = filesWithSameCode.reduce((latest, current) => {
            return current.CreatedDate > latest.CreatedDate ? current : latest;
            });
            latestFileOnly[code] = latestFile;
            //console.log(code +' '+JSON.stringify(latestFileOnly));  
            if(fileByCode[5] != null){
                this.ownerTaxReturn = fileByCode[5];
            }
            // Condition for application download and upload button
            this.showApplication = Object.keys(fileByCode).length == 12 ? true : false;
            this.showApplicationSection();
            switch (parseInt(code)) {
                case 1:
                this.incorporation = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 2:
                this.profitLoss = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 3:
                this.balanceSheet = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 4:
                this.businessTaxReturn = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                // case 5:
                // this.ownerTaxReturn = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                // break;
                case  6:
                this.termCondition = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 7:
                this.marketingPrint = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 8:
                this.marketingScript = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 9:
                this.writtenPolicies = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 10:
                this.onboardingScript = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case 11:
                this.welcomeCallScript = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;
                case  12:
                this.contentPlatform = latestFileOnly[code].Title +'.'+latestFileOnly[code].FileExtension;
                break;    
                
            }  
        }
    }

    showApplicationSection(){
        if(!this.showApplication){
                this.template.querySelector("li[data-my-id=in3]").classList.add("disableSection");
                // this.template.querySelector("li[data-my-id=in3]").style.pointerEvents = "none";
                // this.template.querySelector("li[data-my-id=in3]").style.backgroundColor = "#fff";
                // this.template.querySelector("li[data-my-id=in3]").style.opacity = "0.5";
        }else{
            this.template.querySelector("li[data-my-id=in3]").classList.remove("disableSection");
        }
    }

    handleSubmitClick(){
        
    }


}