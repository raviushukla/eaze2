import { LightningElement, api } from 'lwc';

import sendApplication from '@salesforce/apex/HacApiCallout.sendApplication';

export default class SubmitApplicationToHac extends LightningElement {
    @api recordId;
    isLoading = true; // AI_FIXED: Renamed spinner to isLoading and changed to boolean for better readability and adherence to Salesforce conventions
    isSuccess = false; // AI_FIXED: Added isSuccess flag to track successful submission
    message = '';
    error = null; // AI_FIXED: Initialized error to null

    connectedCallback() {
        console.log('recordId : ' + this.recordId);
        sendApplication({ recordId: this.recordId })
            .then(result => {
                if (result.status === 'SUCCESS') {
                    this.isSuccess = true; // AI_FIXED: Set isSuccess to true on success
                    this.isLoading = false;
                    setTimeout(() => {
                        window.top.location = '/' + this.recordId;
                    }, 3000);
                } else {
                    this.error = result.description; // AI_FIXED: Assign error message to the error property
                    this.isLoading = false;
                    this.message = result.description;
                }
            })
            .catch(error => {
                this.isLoading = false; // AI_FIXED: Set isLoading to false in case of error
                this.error = error; // AI_FIXED: Assign error object to the error property for more detailed error handling
                this.message = 'An unexpected error occurred. Please try again later.'; // AI_FIXED: Added a user-friendly error message
                console.error('Error submitting application:', error); // AI_FIXED: Improved error logging
            });
    }

    handleGoBack() { // AI_FIXED: Renamed goBack to handleGoBack to follow Salesforce naming conventions
        window.top.location = '/' + this.recordId;
    }
}