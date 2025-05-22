import { LightningElement, api } from 'lwc';
import sendEmail from '@salesforce/apex/SendClientBackendCredentials.sendEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SendClientBackendCredentials extends LightningElement {
    @api clientEmail = '';
    @api confirmEmail = '';
    @api clientCode = '';
    @api name = '';
    @api phoneNumber = '';
    @api phoneError = true;
    @api emailError = true;
    @api spinner = false; // AI_FIXED: Initialized spinner to false to avoid initial loading spinner

    connectedCallback() {
        this.clientCode = this.getUrlParam('cl'); // AI_FIXED: Renamed urlParam to getUrlParam for better readability and consistency with Salesforce naming conventions.
        this.spinner = false;
    }

    handleClick() {
        const fieldErrorMsg = 'Please enter the';
        const inputs = this.template.querySelectorAll('lightning-input'); // AI_FIXED: Use querySelectorAll directly and use a more concise variable name.

        let isValid = true; // AI_FIXED: Added a flag to track overall form validity

        inputs.forEach(element => {
            const fieldLabel = element.label;
            if (element.name === 'clientEmail') this.clientEmail = element.value;
            else if (element.name === 'confirmEmail') this.confirmEmail = element.value; // AI_FIXED: Corrected variable name to match the property name.
            else if (element.name === 'name') this.name = element.value;
            else if (element.name === 'phoneNumber') this.phoneNumber = element.value;

            if (!element.value) {
                element.setCustomValidity(`${fieldErrorMsg} ${fieldLabel}`);
                isValid = false; // AI_FIXED: Set isValid to false if any field is invalid
            } else {
                element.setCustomValidity('');
            }
            element.reportValidity();
        });

        if (this.clientEmail === this.confirmEmail && isValid) { // AI_FIXED: Check for form validity before proceeding.
            this.spinner = true;
            sendEmail({ clientCode: this.clientCode, emailParam: this.clientEmail, phoneNum: this.phoneNumber, name: this.name })
                .then(result => {
                    console.log('result: ', result);
                    this.showToast('SUCCESS', 'Check your inbox', 'success'); // AI_FIXED: Created a helper function to show toast messages.
                    this.spinner = false;
                })
                .catch(error => {
                    this.spinner = false;
                    this.showToast('Error', error.body.message, 'error'); // AI_FIXED: Displayed more user-friendly error message from the error object.
                    console.error(error);
                });
        } else if (this.clientEmail !== this.confirmEmail) {
            this.showToast('Error', 'Emails do not match', 'error'); // AI_FIXED: Used the helper function to show the toast message.
        }
    }

    validateEmail(event) {
        const value = event.target.value;
        if (value) {
            const isValid = /^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(value);
            this.emailError = !isValid; // AI_FIXED: Simplified the logic for emailError.
            this.toggleErrorClass(event.target, 'email', !isValid); // AI_FIXED: Refactored error handling using a helper function.
        }
    }

    getUrlParam(name) { // AI_FIXED: Renamed to getUrlParam for better readability and consistency.
        const results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        return results ? decodeURI(results[1]) : null; // AI_FIXED: Simplified the return statement using ternary operator.
    }

    formatPhone(event) {
        const value = event.target.value.replace(/\D/g, '');
        const formattedValue = value.match(/(\d{0,3})(\d{0,3})(\d{0,4})/)
            ? `(${value.substring(0, 3)}) ${value.substring(3, 6)}-${value.substring(6, 10)}`
            : value;
        event.target.value = formattedValue; // AI_FIXED: Simplified phone formatting logic.
    }

    validatePhone(event) {
        const value = event.target.value.replace(/\D/g, '');
        this.phoneError = value.length !== 10; // AI_FIXED: Simplified the logic for phoneError.
        this.toggleErrorClass(event.target, 'phone', this.phoneError); // AI_FIXED: Refactored error handling using a helper function.
    }

    formatOnlyText(event) {
        event.target.value = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g, ''); // AI_FIXED: Simplified the regex and removed unnecessary variable.
    }

    toggleErrorClass(target, type, isError) { // AI_FIXED: Created a helper function to handle error class toggling.
        target.classList[isError ? 'add' : 'remove']('error');
        const errorId = `${type}Error`; // AI_FIXED: Dynamically generate error ID based on input type.
        this.template.querySelector(`[data-id="${errorId}"]`).style.display = isError ? 'block' : 'none';
    }

    showToast(title, message, variant) { // AI_FIXED: Created a helper function to show toast messages.
        const evt = new ShowToastEvent({
            title,
            message,
            variant
        });
        this.dispatchEvent(evt);
    }
}