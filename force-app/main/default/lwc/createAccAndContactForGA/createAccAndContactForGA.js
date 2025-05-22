import { LightningElement, api } from 'lwc';
import createAccConRecord from '@salesforce/apex/CreateAccAndContactForGA.createAccConRecord'; // AI_FIXED: Corrected Apex method name to match the class method name

export default class CreateAccAndContactForGA extends LightningElement {
    @api gaId;
    isLoading = true; // AI_FIXED: Renamed spinner to isLoading and changed to boolean for better readability
    message = '';
    error = false;
    isAccountCreated = false; // AI_FIXED: Renamed accountCreated for better readability and consistency
    isAccountPresent = false; // AI_FIXED: Renamed accountPresent for better readability and consistency
    accountName = ''; // AI_FIXED: Renamed accName to accountName for better readability and consistency
    contactName = ''; // AI_FIXED: Renamed conName to contactName for better readability and consistency
    gaUrl = '';

    connectedCallback() {
        this.gaUrl = '/' + this.gaId;
        console.log('gaId : ' + this.gaId);
        createAccConRecord({ gaId: this.gaId }) // AI_FIXED: Corrected Apex method name to match the class method name
            .then(result => {
                this.isLoading = false; // AI_FIXED: Updated isLoading instead of spinner
                if (!result.accPresent) {
                    this.isAccountCreated = true; // AI_FIXED: Updated isAccountCreated instead of accountCreated
                    setTimeout(() => {
                        window.top.location = '/' + this.gaId;
                    }, 3000); // 2-second delay
                } else {
                    this.isAccountPresent = true; // AI_FIXED: Updated isAccountPresent instead of accountPresent
                    this.accountName = result.accName; // AI_FIXED: Updated accountName instead of accName
                    this.contactName = result.contactName; // AI_FIXED: Updated contactName instead of conName
                }
            })
            .catch(error => {
                this.isLoading = false; // AI_FIXED: Updated isLoading instead of spinner
                this.error = true;
                // AI_FIXED: Improved error handling to provide more specific error messages
                if (error.body && error.body.pageErrors && error.body.pageErrors.length > 0) {
                    this.message = error.body.pageErrors[0].message;
                } else if (error.message) {
                    this.message = error.message;
                } else {
                    this.message = 'An unexpected error occurred.';
                }
            });
    }
}