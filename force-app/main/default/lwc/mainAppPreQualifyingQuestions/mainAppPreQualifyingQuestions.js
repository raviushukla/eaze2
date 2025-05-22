import { LightningElement, api } from 'lwc'; // AI_FIXED: Removed extra space between 'LightningElement' and 'api'

import createLead from '@salesforce/apex/MainAppPreQualifyingQuestions.createLead'; // AI_FIXED: Corrected Apex class name

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
    isRetired = false;
    employmentType = '';

    validateFirstName(event){
        const val = event.target.value;
        this.preFirstNameValue = val;
        this.preFirstNameError = !/^[A-Za-z ]+$/.test(val) && val.length > 1; // AI_FIXED: Simplified validation logic using regex
    }

    validateLastName(event){
        const val = event.target.value;
        this.preLastNameValue = val;
        this.preLastNameError = !/^[A-Za-z ]+$/.test(val) && val.length > 1; // AI_FIXED: Simplified validation logic using regex
    }
    
    validatePhone(event){
        let val = event.target.value.replace(/\D/g, ''); // AI_FIXED: Simplified phone number formatting
        if(val.length > 0){
            val = val.substring(0, 10); // AI_FIXED: Limit phone number to 10 digits
            val = `(${val.substring(0,3)}) ${val.substring(3,6)}-${val.substring(6)}`;
        }
        this.prePhoneValue = val;
        event.target.value = val;
    }

    validatePhoneInput(event){
        this.prePhoneError = event.target.value.length !== 14; // AI_FIXED: Simplified phone number validation
    }

    handleEmailChange(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.preEmailValue = event.target.value;
        this.validateEmail(event.target.value);
    }

    validateEmail(val){
        this.preEmailError = val !== '' && !/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(val); // AI_FIXED: Simplified email validation logic
    }

    handleEmploymentTypeChange(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.employmentType = event.target.value;
        this.isRetired = event.target.value === 'Retired/Benefits/Disability'; // AI_FIXED: Simplified conditional logic
        this.showSection();
    }

    showSection(){
        if(this.isFormValid()){ // AI_FIXED: Created helper function for form validation
            if(this.employmentType === 'W-2'){
                this.w_2Sec = true;
                this.SelfEmployedSec = false;		
            } else if(this.employmentType === 'Self-Employed'){
                this.w_2Sec = false;
                this.SelfEmployedSec = true;
            } else {
                this.moveToApplyPage();
            }
        }
    }

    isFormValid(){ // AI_FIXED: Helper function to check form validity
        return this.preFirstNameValue && this.preLastNameValue && this.prePhoneValue && this.preEmailValue &&
               !this.preFirstNameError && !this.preLastNameError && !this.prePhoneError && !this.preEmailError;
    }

    handleAnnualPreTaxIncomeChange(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.isW2_Ans_1 = true;
        this.isW2_1 = event.target.value === 'Yes'; // AI_FIXED: Simplified conditional logic
        this.moveToApplyPage();
    }

    handleEmployedCurrentEmployerChange(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.isW2_Ans_2 = true;
        this.isW2_2 = event.target.value === 'More than 3 months'; // AI_FIXED: Simplified conditional logic
        this.moveToApplyPage();
    }
    
    handleBusiness2019_2020Change(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.isSelf_Ans_1 = true;
        this.isSelf_1 = event.target.value === 'Yes'; // AI_FIXED: Simplified conditional logic
        this.moveToApplyPage();
    }

    handleTax2019_2020Change(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.isSelf_Ans_2 = true;
        this.isSelf_2 = event.target.value === 'Yes'; // AI_FIXED: Simplified conditional logic
        this.moveToApplyPage();
    }

    handleGrossIncomeChange(event){ // AI_FIXED: Renamed method for clarity and consistency
        this.isSelf_Ans_3 = true;
        this.isSelf_3 = event.target.value === 'Yes'; // AI_FIXED: Simplified conditional logic
        this.moveToApplyPage();
    }
    

    moveToApplyPage(){
        if(this.isRetired){
            this.callParent();
        } else if(this.isW2 && this.isW2_1 && this.isW2_2){ // AI_FIXED: Simplified conditional logic
            this.callParent();
        } else if(this.isW2 && this.isW2_Ans_1 && this.isW2_Ans_2){
            this.showNotMatchMSG();
        } else if(this.isSelf && this.isSelf_1 && this.isSelf_2 && this.isSelf_3){ // AI_FIXED: Simplified conditional logic
            this.callParent();
        } else if(this.isSelf && this.isSelf_Ans_1 && this.isSelf_Ans_2 && this.isSelf_Ans_3){
            this.showNotMatchMSG();
        }
    }
    showNotMatchMSG(){
        this.showSpinner = true;
        const leadData = { // AI_FIXED: Renamed variable for clarity
            firstName : this.preFirstNameValue,
            lastName : this.preLastNameValue,
            email : this.preEmailValue,
            phone : this.prePhoneValue,
            employmentType : this.employmentType,
            clientCode : this.clientCode,
            agentCode : this.agentCode
        };
        createLead({ leadWpObj : leadData }) // AI_FIXED: Used more descriptive variable name
            .then(() => { // AI_FIXED: Removed unnecessary console log and simplified success handling
                window.top.location = 'https://www.eazeconsulting.com/unqualified/';
            })
            .catch(error => { // AI_FIXED: Improved error handling
                this.showSpinner = false; // AI_FIXED: Hide spinner on error
                console.error('Error creating lead:', error);
                // Add more robust error handling here, such as displaying an error message to the user.
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