import { LightningElement, api } from 'lwc';
import submitApplication from '@salesforce/apex/LoanConnectSubmitApplication.SubmitLoanApplication';

export default class LoanConnectOffersLwc extends LightningElement {

    @api leadId;
    preApprovedOffer = false;
    preApprovedDeclined = false;
    submitError = false;
    spinner = true;
    error = '';
    // AI_FIXED: Removed unnecessary leadRecord variable and direct string concatenation
    
    connectedCallback() {
        this.handleApplicationSubmission(); // AI_FIXED: Created a separate method for better readability and maintainability
    }

    handleApplicationSubmission() {
        submitApplication({ leadId: this.leadId })
            .then(result => {
                // AI_FIXED: Improved error handling and type checking
                if (typeof result === 'boolean') {
                    this.preApprovedOffer = result;
                } else if (result === null || result === undefined) {
                    this.error = 'An unexpected error occurred.'; // AI_FIXED: More informative error message
                    this.submitError = true;
                } else {
                    this.error = result; // AI_FIXED: Handle non-boolean results as errors
                    this.submitError = true;
                }
                this.spinner = false;
            })
            .catch(error => {
                this.error = error.body.message; // AI_FIXED: Extract error message from Apex response
                this.submitError = true;
                this.spinner = false;
                console.error('Error submitting application:', error); // AI_FIXED: More informative console log
            });
    }
}