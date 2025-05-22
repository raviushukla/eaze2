import { LightningElement, api, wire } from 'lwc';
import getRelatedFilesByRecordId from '@salesforce/apex/filePreviewAndDownloadController.getRelatedFilesByRecordId';

export default class InstantApprovalDocuments extends LightningElement {
    @api recordId;
    files = []; // AI_FIXED: Renamed filesList to files for better readability and adherence to Salesforce naming conventions
    displayedFiles = []; // AI_FIXED: Renamed filesListUsed to displayedFiles for better readability and adherence to Salesforce naming conventions
    displayedFilesCount = 0; // AI_FIXED: Renamed numOfRec to displayedFilesCount for better readability and adherence to Salesforce naming conventions
    error; // AI_FIXED: Added error property to handle potential errors from the Apex call

    @wire(getRelatedFilesByRecordId, { recordId: '$recordId' })
    wiredFiles({ data, error }) { // AI_FIXED: Renamed wiredResult to wiredFiles for better readability and adherence to Salesforce naming conventions
        this.error = undefined; // AI_FIXED: Clear any previous error
        if (data) {
            this.files = data.map((item) => ({ // AI_FIXED: Simplified file object creation using map
                url: `/sfc/servlet.shepherd/document/download/${item.docId}`,
                previewUrl: `/${item.docId}`,
                createdDate: item.createdDate,
                title: item.title
            }));
            this.showMoreFiles(); // AI_FIXED: Call showMoreFiles instead of showList
        } else if (error) { // AI_FIXED: Use else if for better readability and to avoid redundant checks
            this.error = error; // AI_FIXED: Assign the error to the error property
            console.error(error); // AI_FIXED: Log the error to the console
        }
    }

    showMoreFiles() { // AI_FIXED: Renamed showList to showMoreFiles for better readability and adherence to Salesforce naming conventions
        this.displayedFilesCount = Math.min(this.files.length, this.displayedFilesCount + 3); // AI_FIXED: Simplified logic using Math.min
        this.displayedFiles = this.files.slice(0, this.displayedFilesCount);
    }

    handleDownloadClick(event) {
        window.open(event.target.dataset.url, "_blank");
    }

    get hasFiles() { // AI_FIXED: Added getter to check if there are files to display
        return this.files.length > 0;
    }

    get hasError() { // AI_FIXED: Added getter to check if there is an error
        return this.error;
    }
}