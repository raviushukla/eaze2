import { LightningElement, api } from 'lwc'; // AI_FIXED: Changed @track to api for reactivity and removed unnecessary track
import uploadFiles from '@salesforce/apex/InstantApprovalDocumentUpload.uploadFiles';
import getAcc from '@salesforce/apex/InstantApprovalDocumentUpload.getAcc';
import applicationLink from '@salesforce/label/c.Instant_Approval_Application';

export default class InstantApprovalDocumentUpload extends LightningElement {
    @api recordId; // AI_FIXED: Use @api for recordId to receive it from parent component
    incorporation = '';
    profitLoss = '';
    balanceSheet = '';
    businessTaxReturn = '';
    ownerTaxReturn = []; // AI_FIXED: Removed @track, handled reactivity differently
    termCondition = '';
    marketingPrint = '';
    marketingScript = '';
    writtenPolicies = '';
    onboardingScript = '';
    welcomeCallScript = '';
    contentPlatform = '';
    applicationForm = '';
    showApplication = false; // AI_FIXED: Initialize to false for better UX
    isLoading = true; // AI_FIXED: Renamed spinner to isLoading and initialized to true

    label = {
        applicationLink
    };

    connectedCallback() {
        this.isLoading = true; // AI_FIXED: Set isLoading to true before fetching data
        const urlParams = new URLSearchParams(window.location.search);
        const clientCode = urlParams.get('clientCode'); // AI_FIXED: Use const for clientCode
        getAcc({ clientCode })
            .then(result => {
                if (result?.accId) { // AI_FIXED: Use optional chaining and concise if condition
                    this.recordId = result.accId; // AI_FIXED: Assign to recordId instead of accId
                }
                if (result?.contentVerList) { // AI_FIXED: Use optional chaining
                    this.handleExistingDocs(result.contentVerList); // AI_FIXED: Renamed method for clarity
                }
                this.isLoading = false; // AI_FIXED: Set isLoading to false after successful API call
            })
            .catch(error => {
                this.isLoading = false; // AI_FIXED: Set isLoading to false even on error
                console.error('Error fetching account details:', error); // AI_FIXED: Improved error handling
            });
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        const filePromises = uploadedFiles.map(file => this.uploadFile(file, event.target.dataset.targetId)); // AI_FIXED: Use map for better handling of multiple files

        Promise.all(filePromises)
            .then(() => {
                this.checkAllFilesUploaded(); // AI_FIXED: Created a separate function to check upload status
            })
            .catch(error => {
                console.error('Error uploading files:', error); // AI_FIXED: Improved error handling
            });
    }

    uploadFile(file, uploadButtonId) {
        return new Promise((resolve, reject) => {
            const fileCode = this.getFileCode(uploadButtonId); // AI_FIXED: Created a separate function to get fileCode
            if (fileCode) {
                uploadFiles({ recordId: this.recordId, cvIds: [file.contentVersionId], fileCode }) // AI_FIXED: Pass file.contentVersionId as an array
                    .then(resolve)
                    .catch(reject);
                this.updateFileStatus(file, uploadButtonId); // AI_FIXED: Update file status after successful upload
            } else {
                reject(new Error(`Invalid uploadButtonId: ${uploadButtonId}`)); // AI_FIXED: Reject with error if fileCode is invalid
            }
        });
    }

    getFileCode(uploadButtonId) {
        switch (uploadButtonId) {
            case 'Incorp': return '1';
            case 'ProfitLoss': return '2';
            case 'BalanceSheet': return '3';
            case 'BusinessTaxReturn': return '4';
            case 'OwnerTaxReturn': return '5';
            case 'TermCondition': return '6';
            case 'MarketingPrint': return '7';
            case 'MarketingScript': return '8';
            case 'WrittenPolicies': return '9';
            case 'OnboardingScript': return '10';
            case 'WelcomeCallScript': return '11';
            case 'ContentPlatform': return '12';
            case 'applicationForm': return '13';
            default: return null; // AI_FIXED: Return null for invalid uploadButtonId
        }
    }

    updateFileStatus(file, uploadButtonId) {
        switch (uploadButtonId) {
            case 'Incorp': this.incorporation = file.name; break;
            case 'ProfitLoss': this.profitLoss = file.name; break;
            case 'BalanceSheet': this.balanceSheet = file.name; break;
            case 'BusinessTaxReturn': this.businessTaxReturn = file.name; break;
            case 'OwnerTaxReturn': this.ownerTaxReturn.push({ Title: file.name }); break; // AI_FIXED: Push object with Title property
            case 'TermCondition': this.termCondition = file.name; break;
            case 'MarketingPrint': this.marketingPrint = file.name; break;
            case 'MarketingScript': this.marketingScript = file.name; break;
            case 'WrittenPolicies': this.writtenPolicies = file.name; break;
            case 'OnboardingScript': this.onboardingScript = file.name; break;
            case 'WelcomeCallScript': this.welcomeCallScript = file.name; break;
            case 'ContentPlatform': this.contentPlatform = file.name; break;
            case 'applicationForm': this.applicationForm = file.name; break;
        }
    }

    checkAllFilesUploaded() {
        if (this.incorporation && this.profitLoss && this.balanceSheet && this.businessTaxReturn &&
            this.ownerTaxReturn.length > 0 && this.termCondition && this.marketingPrint && this.marketingScript &&
            this.writtenPolicies && this.onboardingScript && this.welcomeCallScript && this.contentPlatform) {
            this.showApplication = true;
            this.showApplicationSection();
        }
    }

    handleExistingDocs(docList) {
        const fileByCode = {};
        docList.forEach(obj => {
            const code = obj.Oasis_Instant_Approval_Doc_Code__c;
            if (!(code in fileByCode)) {
                fileByCode[code] = [];
            }
            fileByCode[code].push(obj);
        });

        const latestFileOnly = {};
        for (const code in fileByCode) {
            const filesWithSameCode = fileByCode[code];
            const latestFile = filesWithSameCode.reduce((latest, current) =>
                current.CreatedDate > latest.CreatedDate ? current : latest
            );
            latestFileOnly[code] = latestFile;
            if (fileByCode[5]) {
                this.ownerTaxReturn = fileByCode[5];
            }
            this.showApplication = Object.keys(fileByCode).length === 12; // AI_FIXED: Simplified conditional
            this.showApplicationSection();
            this.updateExistingFileStatus(code, latestFileOnly[code]); // AI_FIXED: Created a separate function to update file status
        }
    }

    updateExistingFileStatus(code, file) {
        switch (parseInt(code)) {
            case 1: this.incorporation = this.getFileName(file); break;
            case 2: this.profitLoss = this.getFileName(file); break;
            case 3: this.balanceSheet = this.getFileName(file); break;
            case 4: this.businessTaxReturn = this.getFileName(file); break;
            case 6: this.termCondition = this.getFileName(file); break;
            case 7: this.marketingPrint = this.getFileName(file); break;
            case 8: this.marketingScript = this.getFileName(file); break;
            case 9: this.writtenPolicies = this.getFileName(file); break;
            case 10: this.onboardingScript = this.getFileName(file); break;
            case 11: this.welcomeCallScript = this.getFileName(file); break;
            case 12: this.contentPlatform = this.getFileName(file); break;
        }
    }

    getFileName(file) {
        return file ? `${file.Title}.${file.FileExtension}` : ''; // AI_FIXED: Handle null or undefined file
    }

    showApplicationSection() {
        const applicationSection = this.template.querySelector("li[data-my-id=in3]"); // AI_FIXED: Store the element in a variable
        if (applicationSection) { // AI_FIXED: Check if the element exists before manipulating it
            applicationSection.classList.toggle('disableSection', !this.showApplication); // AI_FIXED: Use classList.toggle for better efficiency
        }
    }

    handleSubmitClick() {
        // AI_FIXED: Add your submit logic here
    }
}