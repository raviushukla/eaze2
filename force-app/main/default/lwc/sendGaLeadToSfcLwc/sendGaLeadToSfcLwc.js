import { LightningElement, api } from 'lwc';

import makeXMLCallout from '@salesforce/apex/SFC_XmlCallOut.makeXMLCallout';

export default class SendGaLeadToSfcLwc extends LightningElement {
    @api gaLeadId;
    isLoading = true; // AI_FIXED: Renamed spinner to isLoading and changed to boolean for better readability and adherence to LWC best practices.
    message = '';
    isError = false; // AI_FIXED: Renamed error to isError for better readability and adherence to LWC best practices.
    isSuccess = false; // AI_FIXED: Added isSuccess flag to track successful processing.

    connectedCallback() {
        console.log('gaId : ' + this.gaLeadId);
        makeXMLCallout({ leadId: this.gaLeadId })
            .then(result => {
                if (result === 'PROCESSED') {
                    this.isSuccess = true; // AI_FIXED: Set isSuccess to true on successful processing.
                    this.isLoading = false;
                    setTimeout(() => {
                        window.top.location = '/' + this.gaLeadId;
                    }, 3000); // 3-second delay
                } else {
                    this.isError = true; // AI_FIXED: Set isError to true on error.
                    this.isLoading = false;
                    this.message = result;
                }
            })
            .catch(error => {
                this.isLoading = false; // AI_FIXED: Set isLoading to false even on error.
                this.isError = true; // AI_FIXED: Set isError to true on error.
                this.message = error.body.message || 'An unexpected error occurred.'; // AI_FIXED: Improved error handling to display a user-friendly message.
                console.error('Error processing lead:', error); // AI_FIXED: Added more informative console logging.
            });
    }

    handleGoBack() { // AI_FIXED: Renamed goBack to handleGoBack for better naming convention.
        window.top.location = '/' + this.gaLeadId;
    }
}