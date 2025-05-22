import { LightningElement,api } from 'lwc';

import sendApplication from '@salesforce/apex/HacApiCallout.sendApplication';

export default class SubmitApplicationToHac extends LightningElement {
    
    @api recordId;
    spinner = true;
    message = '';
    error = false;
    noError = false;
    connectedCallback() {
        console.log('recordId : '+ this.recordId);
        sendApplication({recordId : this.recordId})
        .then(result =>{
            if(result.status == 'SUCCESS'){
                this.noError = true;
                this.spinner = false;
                setTimeout(() => {
                    window.top.location = '/'+this.recordId;                                                                                
                }, 3000); // 3-second delay
            }else{
                this.error = true;
                this.spinner = false;
                this.message = result.description;
            }
        }).catch(error =>{
            console.log(error);
        });
    }
    goBack(){
        window.top.location = '/'+this.recordId;  
    }
}