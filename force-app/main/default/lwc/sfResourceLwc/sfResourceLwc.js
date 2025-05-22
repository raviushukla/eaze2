import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import sendNotifications from '@salesforce/apex/SfResourceLwcApex.sendNotifications';
import { CloseActionScreenEvent } from 'lightning/actions';

export default class SfResourceLwc extends LightningElement {
    spinner = true;
    _recordId;
    @api
    get recordId() {
        return this._recordId;
    }
    
    set recordId(value) {
        if (value !== this._recordId) {
            this._recordId = value;
            sendNotifications({recordId : this._recordId})
            .then(result =>{
                this.spinner = false;
                const evt = new ShowToastEvent({
                    title: 'Success',
                    message: 'Notifications send successfully',
                    variant: 'success',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            }).catch(error =>{
                this.spinner = false;
                const evt = new ShowToastEvent({
                    title: 'Error',
                    message: 'Some unexpected error '+error.body.message,
                    variant: 'error',
                    mode: 'dismissable'
                });
                this.dispatchEvent(evt);
                this.dispatchEvent(new CloseActionScreenEvent());
            });
        }
    }
    
    

    // @api recordId;
    // @api invoke() {
    //     console.log(this.recordId);
    //   }
    // connectedCallback(){
    //     /*sendNotifications({recordId : this.recordId})
    //     .then(result =>{
    //         const evt = new ShowToastEvent({
    //             title: 'Success',
    //             message: 'Notifications send successfully',
    //             variant: 'success',
    //             mode: 'dismissable'
    //         });
    //         this.dispatchEvent(evt);
    //         this.dispatchEvent(new CloseActionScreenEvent());
    //     }).catch(error =>{
    //         const evt = new ShowToastEvent({
    //             title: 'Error',
    //             message: 'Some unexpected error '+error,
    //             variant: 'error',
    //             mode: 'dismissable'
    //         });
    //         this.dispatchEvent(evt);
    //         this.dispatchEvent(new CloseActionScreenEvent());
    //     });*/
    // }
    // renderedCallback() {
    //     console.log('rendered------------');
    //     console.log(this.recordId + ' is provided');
    // }
}