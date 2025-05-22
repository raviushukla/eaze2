import { LightningElement, api } from 'lwc';

import updateContact from '@salesforce/apex/LwcUnsubscribePrimaryContactController.updateContact';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LwcUnsubscribePrimaryContact extends LightningElement {
    @api email; // AI_FIXED: Changed email to be an @api property to receive email from parent component
    isLoading = false; // AI_FIXED: Renamed spinner to isLoading and changed to false initially
    emailError = false; // AI_FIXED: Initialized emailError to false

    connectedCallback(){
        // AI_FIXED: Removed URL parameter retrieval, relying on @api email property
        this.isLoading = false; // AI_FIXED: Set isLoading to false after component initialization
    }

    handleUnsubscribe(){ // AI_FIXED: Renamed handleClick to handleUnsubscribe for clarity
        this.isLoading = true; // AI_FIXED: Set isLoading to true before API call
        if(this.email && this.validateEmail(this.email)){ // AI_FIXED: Call validateEmail before API call and use the return value
            updateContact({email : this.email})
            .then(result =>{
                console.log('result : ',result);
                this.showToast('SUCCESS', 'Unsubscribed from our list', 'success'); // AI_FIXED: Use helper method for toast
                this.isLoading = false;
            }).catch(error =>{
                this.isLoading = false;
                this.showToast('Error', error.body.message, 'error'); // AI_FIXED: Show specific error message from the response
                console.error(error); // AI_FIXED: Use console.error for error logging
            });
        }else{
            this.showToast('Error', 'Incorrect Email', 'error'); // AI_FIXED: Use helper method for toast
        }
    }

    validateEmail(email){ // AI_FIXED: Created a separate function for email validation
        // AI_FIXED: Improved regex for email validation
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }

    showToast(title, message, variant){ // AI_FIXED: Created a helper method for showing toast
        const evt = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
        });
        this.dispatchEvent(evt);
    }
}