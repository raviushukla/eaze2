import { LightningElement, api } from 'lwc';
import submitApplication from '@salesforce/apex/LoanConnectSubmitApplication.SubmitLoanApplication';

export default class LoanConnectOffersLwc extends LightningElement {

    @api leadId;
    preApprovedOffer = false;
    preApprovedDeclined = false;
    submitError = false;
    spinner = true;
    leadRecord = '';
    error = '';
    connectedCallback() {
        this.leadRecord = '/'+this.leadId;
        submitApplication({leadId : this.leadId})
        .then(result =>{
            console.log('result', result);
            if(result == 'true'){
                this.preApprovedOffer = true;
            }else if(result == 'false'){
                this.preApprovedDeclined = true;
            }else{
                this.error = result;
                this.submitError = true;
            }
            
            this.spinner = false;
        }).catch(error =>{
            console.log(error);
        });
    }
}