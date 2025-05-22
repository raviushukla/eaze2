import { LightningElement,api } from 'lwc';

import makeXMLCallout from '@salesforce/apex/SFC_XmlCallOut.makeXMLCallout';

export default class SendGaLeadToSfcLwc extends LightningElement {
    
    @api gaLeadId;
    spinner = true;
    message = '';
    error = false;
    noError = false;
    connectedCallback() {
        console.log('gaId : '+ this.gaLeadId);
        makeXMLCallout({leadId : this.gaLeadId})
        .then(result =>{
            if(result == 'PROCESSED'){
                this.noError = true;
                this.spinner = false;
                setTimeout(() => {
                    window.top.location = '/'+this.gaLeadId;                                                                                
                }, 3000); // 3-second delay
            }else{
                this.error = true;
                this.spinner = false;
                this.message = result;
            }
        }).catch(error =>{
            console.log(error);
        });
    }
    goBack(){
        window.top.location = '/'+this.gaLeadId;  
    }
}