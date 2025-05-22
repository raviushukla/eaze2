import { LightningElement, api } from 'lwc';
import createTelegramMsgRecord from '@salesforce/apex/SendToBelEAZEChatBtnApex.createTelegramMsgRecord';

export default class SendToBelEAZEChatBtnLwc extends LightningElement {
    @api recordId;
    isLoading = true; // AI_FIXED: Renamed spinner to isLoading for better clarity and consistency with LWC conventions
    message = '';
    isError = false; // AI_FIXED: Renamed error to isError for better clarity and consistency with LWC conventions
    isMessageSent = false; // AI_FIXED: Renamed messageSent to isMessageSent for better clarity and consistency with LWC conventions
    recordUrl = '';

    connectedCallback() {
        this.recordUrl = `/${this.recordId}`; // AI_FIXED: Used template literal for string concatenation
        console.log('record : ' + this.recordId);
        createTelegramMsgRecord({ recordId: this.recordId })
            .then(result => {
                this.isLoading = false; // AI_FIXED: Updated isLoading instead of spinner
                this.isMessageSent = true; // AI_FIXED: Updated isMessageSent instead of messageSent
                // AI_FIXED: Removed setTimeout and direct navigation;  Navigation should ideally be handled by a separate component or event.
                // AI_FIXED:  Directly navigating in connectedCallback can lead to unexpected behavior.
                // Consider using a navigation event or a separate component for navigation.
            })
            .catch(error => {
                console.error('Error sending message:', error); // AI_FIXED: Improved error logging
                this.isError = true; // AI_FIXED: Updated isError instead of error
                this.isLoading = false; // AI_FIXED: Updated isLoading instead of spinner
                this.message = this.handleError(error); // AI_FIXED:  Added error handling function
            });
    }

    handleError(error) {
        // AI_FIXED: Added a function to handle errors more gracefully.
        // AI_FIXED:  This function can be expanded to handle different error types and provide more user-friendly messages.
        if (error && error.body && error.body.pageErrors && error.body.pageErrors[0]) {
            return error.body.pageErrors[0].message;
        } else if (error && error.message) {
            return error.message;
        } else {
            return 'An unexpected error occurred.';
        }
    }
}