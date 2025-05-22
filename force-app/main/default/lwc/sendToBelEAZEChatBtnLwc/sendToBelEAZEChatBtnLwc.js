import { LightningElement, api } from 'lwc';
import createTelegramMsgRecord from '@salesforce/apex/SendToBelEAZEChatBtnApex.createTelegramMsgRecord';

export default class SendToBelEAZEChatBtnLwc extends LightningElement {
    @api recordId;
    spinner = true;
    message = '';
    error = false;
    messageSent = false;
    recordUrl = '';

    connectedCallback() {
        this.recordUrl = '/'+this.recordId; 
        console.log('record : '+ this.recordId);
        createTelegramMsgRecord({recordId : this.recordId})
        .then(result =>{
            this.spinner = false;
            this.messageSent = true;
            setTimeout(() => {
                window.top.location = '/'+this.recordId;                                                                                
            }, 3000); // 3-second delay
        }).catch(error =>{
            console.log();
            this.error = true;
            this.spinner = false;
            const pageError = error.body.pageErrors[0];
            this.message = pageError.message;
        });
    }
}