import { LightningElement } from 'lwc';
import sendEmail from '@salesforce/apex/SendClientBackendCredentials.sendEmail';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class SendClientBackendCredentials extends LightningElement {

    clientEmail ='';
    confirmEmial ='';
    clientCode = '';
    name = '';
    phoneNumber = '';
    phoneError = true;
    emailError = true;
    spinner = true;

    connectedCallback(){
        this.clientCode  = this.urlParam('cl');
        this.spinner = false;
    }

    handleClick(event){
        let fieldErrorMsg="Please Enter the";
        var inp=this.template.querySelectorAll("lightning-input");
        inp.forEach(function(element){
            let fieldLabel=element.label;  
            if(element.name=="input1")
                this.clientEmail=element.value;
            else if(element.name=="input2")
                this.confirmEmial=element.value;
            else if(element.name=="input3")
                this.name = element.value;
            else if(element.name=="input4")
                this.phoneNumber = element.value;

                if(!element.value){
                    element.setCustomValidity(fieldErrorMsg+' '+fieldLabel);
                }
                else{
                    element.setCustomValidity("");
                }
                element.reportValidity();

        },this);

        if(this.clientEmail == this.confirmEmial){
            if(this.name != '' && this.phoneError == false && this.emailError == false){
                this.spinner = true;
                sendEmail({clientCode : this.clientCode, emailParam : this.clientEmail, phoneNum : this.phoneNumber, name : this.name})
                .then(result =>{
                    console.log('result : ',result);
                    const evt = new ShowToastEvent({
                        title: 'SUCCESS',
                        message: 'Check your inbox',
                        variant: 'success',
                    });
                    this.dispatchEvent(evt);
                    this.spinner = false;
                }).catch(error =>{
                    this.spinner = false;
                    alert(error);
                    console.log(error);
                });
            }
        }else{
            const evt = new ShowToastEvent({
                title: 'Error',
                message: 'Emails do not match',
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
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }else{
                event.target.classList.add('error');
                this.emailError = true;
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }
        }
        
    }

    urlParam(name){
        var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        if (results==null){
           return null;
        }
        else{
           return decodeURI(results[1]) || 0;
        }
    }

    formatPhone(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,4})/);
            event.target.value = !x[2] ? x[1] : '(' + x[1] + ') ' + x[2] + (x[3] ? '-' + x[3] : '');
        }

    }

    validatePhone(event){
        var errorId = event.target.name +'_Id';
        if(event.target.value.length > 0){
            var x = event.target.value.replace(/\D/g, '');
            if(x.length != 10){
                event.target.classList.add('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="block";
            }else{
                this.phoneError = false;
                event.target.classList.remove('error');
                this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
            }
        }else{
            this.phoneError = true;
            event.target.classList.remove('error');
            this.template.querySelector('[data-id="'+errorId+'"]').style.display="none";
        }
        
    }

    formatOnlyText(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/^[0-9!@#\$%\^\&*\)\(+=._-]+$/g,'');
            event.target.value = x;
        }
    }

}