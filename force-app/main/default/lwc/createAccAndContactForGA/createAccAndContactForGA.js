import { LightningElement, api } from 'lwc';
import createRecord from '@salesforce/apex/CreateAccAndContactForGA.createAccConRecord';

export default class CreateAccAndContactForGA extends LightningElement {

    @api gaId;
    spinner = true;
    message = '';
    error = false;
    accountCreated = false;
    accountPresent = false;
    accName = '';
    conName = '';
    gaUrl = '';
    connectedCallback() {
        this.gaUrl = '/'+this.gaId; 
        console.log('gaId : '+ this.gaId);
        createRecord({gaId : this.gaId})
        .then(result =>{
            this.spinner = false;
            if(!result.accPresent){
                this.accountCreated = true;
                setTimeout(() => {
                    window.top.location = '/'+this.gaId;                                                                                
                }, 3000); // 2-second delay
            }else{
                this.accountPresent = true;
                this.accName = result.accName;
                this.conName = result.contactName;
            }
        }).catch(error =>{
            console.log();
            this.error = true;
            this.spinner = false;
            const pageError = error.body.pageErrors[0];
            this.message = pageError.message;
        });
    }
}