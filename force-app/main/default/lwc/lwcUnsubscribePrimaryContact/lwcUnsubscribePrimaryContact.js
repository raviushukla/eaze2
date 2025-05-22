import { LightningElement } from 'lwc';

import updateContact from '@salesforce/apex/LwcUnsubscribePrimaryContactController.updateContact';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class LwcUnsubscribePrimaryContact extends LightningElement {
    email = '';
    spinner = true;
    emailError = true;
    connectedCallback(){
        const queryString = window.location.search;
        const urlParams = new URLSearchParams(queryString);
        this.email = urlParams.get('email');
        this.spinner = false;
    }

    handleClick(event){
        let fieldErrorMsg="Please Enter the";
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            let fieldLabel=element.label;  
            if(element.name=="input1")
                this.clientEmail=element.value;

                if(!element.value){
                    element.setCustomValidity(fieldErrorMsg+' '+fieldLabel);
                }
                else if(/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(element.value)){
                    element.setCustomValidity("");
                    this.emailError = false;
                }
                element.reportValidity();

        },this);

        if(this.email && !this.emailError){
            this.spinner = true;
            updateContact({email : this.email})
            .then(result =>{
                console.log('result : ',result);
                const evt = new ShowToastEvent({
                    title: 'SUCCESS',
                    message: 'Unsubscribed from our list',
                    variant: 'success',
                });
                this.dispatchEvent(evt);
                this.spinner = false;
            }).catch(error =>{
                this.spinner = false;
                alert(JSON.stringify(error));
                console.log(error);
            });
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Incorrect Email',
                variant: 'error',
              });
              this.dispatchEvent(evt);
        }


        
    }

    validateEmail(event){
        if(event.target.value != null){
            var errorId = event.target.fieldName +'_Id';
            if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(event.target.value)){
                this.emailError = false;
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }else{
                this.emailError = true;
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }
        }
        
    }
    
}