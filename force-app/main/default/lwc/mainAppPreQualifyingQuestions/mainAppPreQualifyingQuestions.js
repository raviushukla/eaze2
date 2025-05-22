import { LightningElement,api } from 'lwc';

import createLead from '@salesforce/apex/MainAppPreQualiyingQuestions.createLead';

export default class MainAppPreQualifyingQuestions extends LightningElement {

    @api clientCode;
    @api agentCode;

    showSpinner = false;
    preFirstNameValue = '';
    preFirstNameError = false;
    preLastNameValue = '';
    preLastNameError = false;
    prePhoneValue = '';
    prePhoneError = false;
    preEmailValue = '';
    preEmailError = false;
    isW2 = false;
    isSelf = false;
    isRetired = false;
    w_2Sec = false;
    SelfEmployedSec = false;
    isW2_1 = false;
    isW2_Ans_1 = false;
    isW2_Ans_2 = false;
    isW2_2 = false;
    isSelf_Ans_1 = false;
    isSelf_1 = false;
    isSelf_Ans_2 = false;
    isSelf_2 = false;
    isSelf_Ans_3 = false;
    isSelf_3 = false;
    employmentType = '';

    validateFirstName(event){
        if(event.target.value.length > 1){
            var letters = /^[A-Za-z ]+$/;
            var val = event.target.value;
            this.preFirstNameValue = val;
            if(!val.match(letters)){
                this.preFirstNameError = true;
            }else{
                this.preFirstNameError = false;
            }
        }
    }

    validateLastName(event){
        if(event.target.value.length > 1){
            var letters = /^[A-Za-z ]+$/;
            var val = event.target.value;
            this.preLastNameValue = val;
            if(!val.match(letters)){
                this.preLastNameError = true;
            }else{
                this.preLastNameError = false;
            }
        }
    }
    
    validatePhone(event){;
        var val = event.target.value;
        if( val.length > this.prePhoneValue.length ){
            var r = /(\D+)/g,
            npa = '',
            nxx = '',
            last4 = '';
            val = val.replace(r, '');
            npa = val.substr(0, 3);
            nxx = val.substr(3, 3);
            last4 = val.substr(6, 4);

            if( val.length > 0 && val.length < 4 ){
                val = '(' + val + ')';  
            }else if( val.length > 3 && val.length < 7){
                val = '(' + npa + ') ' + nxx;    
            }else if( val.length > 6 ){
                val = '(' + npa + ') ' + nxx + '-' + last4;
            }
        }

        this.prePhoneValue = val;
        event.target.value = val;
    }

    validatePhoneInput(event){
        console.log('On focus out '+event.target.value.length);
        if(event.target.value.length != 14){
            this.prePhoneError = true;
        }else{
            this.prePhoneError = false;
        }
    }

    setEmailValue(event){
        this.preEmailValue = event.target.value;
        this.validateEmail(event.target.value);

    }

    validateEmail(val){
        console.log('evn hit',val);
        if(this.preEmailValue == ''){
            this.preEmailError = false;
            return false;
        }
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(val)){
            console.log('no error ');
            this.preEmailError = false;
            return true;
        }else{
            console.log('email error');
            this.preEmailError = true;
            return false;
        }
    }

    empmntHandle(event){
        this.employmentType = event.target.value;
        if(event.target.value=='Retired/Benefits/Disability'){
            this.isW2 = false;
            this.isSelf = false;
            this.isRetired = true;
        }else if(event.target.value=='W-2'){
            this.isW2 = true;
            this.isSelf = false;
            this.isRetired = false;
        }else{
            this.isSelf = true;
            this.isW2 = false;
            this.isRetired = false;
        }
        //hideNotMatchMSG();
        this.showSection();
    }

    showSection(){
        this.w_2Sec = false;
        this.SelfEmployedSec = false;
        if(this.preFirstNameValue && this.preLastNameValue && this.prePhoneValue && this.preEmailValue && !this.preFirstNameError && !this.preLastNameError && !this.prePhoneError && !this.preEmailError && this.isW2){
            this.w_2Sec = true;
            this.SelfEmployedSec = false;		
        }else if(this.preFirstNameValue && this.preLastNameValue && this.prePhoneValue && this.preEmailValue && !this.preFirstNameError && !this.preLastNameError && !this.prePhoneError && !this.preEmailError && this.isSelf){
            this.w_2Sec = false;
            this.SelfEmployedSec = true;
        }else if(this.preFirstNameValue && this.preLastNameValue && this.prePhoneValue && this.preEmailValue && !this.preFirstNameError && !this.preLastNameError && !this.prePhoneError && !this.preEmailError && this.isRetired){
            this.moveToApplyPage();
        }
    }
    
    annualPreTaxIncomeHandle(event){
        this.isW2_Ans_1 = true;
        if(event.target.value == 'Yes'){
            this.isW2_1 = true;
        }else{
            this.isW2_1 = false;
            //hideQues('pqQuesSection');
        }
        this.moveToApplyPage();
    }

    employedCurrentEmployerHandle(event){
        this.isW2_Ans_2 = true;
        if(event.target.value=='More than 3 months'){
            this.isW2_2 = true;
        }else{
            this.isW2_2 = false;
            //hideQues('pqQuesSection');
        }
        this.moveToApplyPage();
    }
    
    business2019_2020Handle(event){
        this.isSelf_Ans_1 = true;
        if(event.target.value=='Yes'){
            this.isSelf_1 = true;
            //jq("#taxReturn").val("Yes");
        }else{
            this.isSelf_1 = false;
            //jq("#taxReturn").val("No");
            //hideQues('pqQuesSection');
        }
        this.moveToApplyPage();
    }

    tax2019_2020Handle(event){
        this.isSelf_Ans_2 = true;
        if(event.target.value=='Yes'){
            this.isSelf_2 = true;
        }else{
            this.isSelf_2 = false;
            //hideQues('pqQuesSection');
        }
        this.moveToApplyPage();
    }

    grossIncomeHandle(event){
        this.isSelf_Ans_3 = true;
        if(event.target.value=='Yes'){
            this.isSelf_3 = true;
        }else{
            this.isSelf_3 = false;
            //hideQues('pqQuesSection');
        }
        this.moveToApplyPage();
    }
    

    
    moveToApplyPage(){
        if(this.isRetired){
            this.callParent();
        }
        else if(this.isW2){
            if(this.isW2_1 && this.isW2_2){
                this.callParent();
            }else if(this.isW2_Ans_1 && this.isW2_Ans_2){
                this.showNotMatchMSG();
            }
        }else{
            if(this.isSelf_1 && this.isSelf_2 && this.isSelf_3){
                this.callParent();
            }else if(this.isSelf_Ans_1 && this.isSelf_Ans_2 && this.isSelf_Ans_3){
                this.showNotMatchMSG();
            }
        }
    }
    showNotMatchMSG(){
        console.log(this.clientCode);
        this.showSpinner = true;
            let obj = {
                firstName : this.preFirstNameValue,
                lastName : this.preLastNameValue,
                email : this.preEmailValue,
                phone : this.prePhoneValue,
                employmentType : this.employmentType,
                clientCode : this.clientCode,
                agentCode : this.agentCode
            }
            console.log(obj);
            createLead({ leadWpObj : obj })
            .then((result) => {
                window.top.location = 'https://www.eazeconsulting.com/unqualified/';
                
            }).catch((error) =>{
                console.log('having error', error );
            });
    }

    callParent() {
        this.dispatchEvent(new CustomEvent('nextpage', {
            detail: {
                page1: true,
                page1a: false,
                firstName : this.preFirstNameValue,
                lastName: this.preLastNameValue,
                phone: this.prePhoneValue,
                email: this.preEmailValue
            }
        }));
    }

}