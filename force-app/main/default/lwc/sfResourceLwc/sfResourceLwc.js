import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendNotifications from '@salesforce/apex/SfResourceLwcApex.sendNotifications';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SfResourceLwc extends LightningElement {
    spinner = true;
    recordId; // AI_FIXED: Removed the underscore and made it a public property for better access.

    connectedCallback() { // AI_FIXED: Moved the Apex call to connectedCallback for better lifecycle management.
        if (this.recordId) {
            this.handleSendNotifications();
        }
    }

    @api
    set recordId(value) {
        this.recordId = value; // AI_FIXED: Directly assign the value to the public property.
        if (value) {
            this.handleSendNotifications(); // AI_FIXED: Call the helper function to send notifications.
        }
    }

    handleSendNotifications() { // AI_FIXED: Created a helper function to encapsulate the Apex call.
        sendNotifications({ recordId: this.recordId })
            .then(result => {
                this.spinner = false;
                this.showToast('Success', 'Notifications sent successfully', 'success');
                this.dispatchEvent(new CloseActionScreenEvent());
            })
            .catch(error => {
                this.spinner = false;
                this.showToast('Error', `An unexpected error occurred: ${error.body.message}`, 'error'); // AI_FIXED: Improved error message.
                this.dispatchEvent(new CloseActionScreenEvent());
            });
    }

    showToast(title, message, variant) { // AI_FIXED: Created a helper function to show toast messages.
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(evt);
    }
}