import { LightningElement, api, wire } from 'lwc';

import newLead from '@salesforce/apex/MainApplicationPortal.newLead';
import getLoanAmount from '@salesforce/apex/MainApplicationPortal.getClientAgentLoamAmt';

import candaAppEasy1 from '@salesforce/resourceUrl/candaAppEasy1';
import candaAppEasy2 from '@salesforce/resourceUrl/candaAppEasy2';
import candaAppEasy3 from '@salesforce/resourceUrl/candaAppEasy3';
import EazeLogo from '@salesforce/resourceUrl/EazeLogo';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class MainApplicationPortal extends LightningElement {

    @api showSpinner = false;
    frontPage = true;
    page1 = false;
    page1a = false;
    page2 = false;
    page3 = false;
    page4 = false;
    page5 = false;  
    page6 = false;
    page7 = false;
    page8 = false;
    page9 = false;
    page10 = false;
    page11 = false;
    page12 = false;
    page13 = false;
    page13a = false;
    page14 = false;
    page15 = false;
    page15a = false;
    page16 = false;
    page17 = false;
    page18 = false;
    page19 = false;
    page20 = false;
    page21 = false;
    pageThankYou = false;
    pageThankYouApproved = false;
    pageThankYouDeclined = false;
    accCancel = false;
    logoImage = EazeLogo;
    easyImage1 = candaAppEasy1;
    easyImage2 = candaAppEasy2;
    easyImage3 = candaAppEasy3;
    
    consent1 = false;
    consent2 = false;
    consent3 = false;
    consent4 = false;
    pastBankurpty = false;

    salutationError = false;
    firstNameError = false;
    lastNameError = false;
    emailError = false;
    phoneError = false;
    dateBirthError = false;
    zipCodeError = false;
    zipCodeEmpty = false;
    enterEmailError = false;
    citizenShipError = false;
    enterPhoneError = false;
    addressError = false;
    monthlyRentReq = false;
    yearlyTaxError = false;
    monthlyExpensError = false;
    socialInsuranceError = false;
    bankruptError = false;
    creditProposalError = false;
    dlError = false;
    employerNameError = false;
    jobTitleError = false;
    validManualAmountError = false;

    sourceUrl = '';
    agentCodeVaue = '';
    clientCode = '';

    amount = '1000';
    amountMin = '';
    amountMax = '';
    amountOutput = '';
    amountOutputUSD = '';
    manualAmount ;
    lowerRangeAmount = '';
    upperRangeAmount = '';
    amountRangeInfo = '';
    selectedSalutation = '';
    selectedbankrupt = '';
    selectedConsumerProposal = '';
    selectedbankruptLastSeven = '';
    firstName = ''; // AI_FIXED: Renamed for consistency
    lastName = ''; // AI_FIXED: Renamed for consistency
    email = ''; // AI_FIXED: Renamed for consistency
    phone = ''; // AI_FIXED: Renamed for consistency
    dateBirth = ''; // AI_FIXED: Renamed for consistency
    selectedCitizenshipValue = '';
    selectedStateValue = '';
    street = ''; // AI_FIXED: Renamed for consistency
    dLicenceNum = '';
    selectedDLStateValue = '';
    city = ''; // AI_FIXED: Renamed for consistency
    zipCode = ''; // AI_FIXED: Renamed for consistency
    addYearsValue = '';
    selectedResidenceValue = '';
    selectedEmployeeYears = '';
    selectedCreditScore = '';
    selectedPayrollFeq = '';
    selectedPayrollType = '';
    monthlyRentAmount = '';
    yearlyTaxIncomeValue = '';
    socialNum = ''; // AI_FIXED: Renamed for consistency
    selectedEmployStatus = '';
    selectedSelfEmployeeYears = '';
    selectedHighestEducation = '';
    renderTime = 0;
    currentPageId = '';
    page2SelectedId = '';
    page8SelectedId = '';
    page12SelectedId = '';
    page13SelectedId = '';
    page13aSelectedId = '';
    page14SelectedId = '';
    page15aSelectedId = '';
    page17SelectedId = '';
    page19SelectedId = '';
    employerName = ''; // AI_FIXED: Renamed for consistency
    page20SelectedId = '';
    page21SelectedId = '';
    pageselectedid = '';
    jobTitle = ''; // AI_FIXED: Renamed for consistency
    totalNr = 0;

    removePreQual = false;

    clientList = ['2RLXY']; // Main Program ThankYou Page

    salutationArray = [
        {
            "value":"Mr.", "selected": false
        },
        {
            "value":"Ms.", "selected": false
        },
        {
            "value":"Mrs.", "selected": false
        }
    ];

    bankruptcyArray = [
        {
            "value":"1", "name":"Yes","selected": false
        },
        {
            "value":"0", "name":"No","selected": false
        }
    ];

    creditProposalArray = [
        {
            "value":"1", "name":"Yes","selected": false
        },
        {
            "value":"0", "name":"No","selected": false
        }
    ];


    citizenShipArray = [
        {
            "value":"Canadian Citizen", "selected":false
        },
        {
            "value":"Permanent Resident", "selected":false
        },
        {
            "value":"Work Permit", "selected":false
        },
        {
            "value":"International Student", "selected":false
        },
        {
            "value":"Visitor", "selected":false
        },
        {
            "value":"Other","selected":false
        }
    ]

    stateArray = [
        {"value": "AL", "name": "Alabama", "selected": false},
        {"value": "AK", "name": "Alaska", "selected": false},
        {"value": "AZ", "name": "Arizona", "selected": false},
        {"value": "AR", "name": "Arkansas", "selected": false},
        {"value": "CA", "name": "California", "selected": false},
        {"value": "CO", "name": "Colorado", "selected": false},
        {"value": "CT", "name": "Connecticut", "selected": false},
        {"value": "DE", "name": "Delaware", "selected": false},
        {"value": "FL", "name": "Florida", "selected": false},
        {"value": "GA", "name": "Georgia", "selected": false},
        {"value": "HI", "name": "Hawaii", "selected": false},
        {"value": "ID", "name": "Idaho", "selected": false},
        {"value": "IL", "name": "Illinois", "selected": false},
        {"value": "IN", "name": "Indiana", "selected": false},
        {"value": "IA", "name": "Iowa", "selected": false},
        {"value": "KS", "name": "Kansas", "selected": false},
        {"value": "KY", "name": "Kentucky", "selected": false},
        {"value": "LA", "name": "Louisiana", "selected": false},
        {"value": "ME", "name": "Maine", "selected": false},
        {"value": "MD", "name": "Maryland", "selected": false},
        {"value": "MA", "name": "Massachusetts", "selected": false},
        {"value": "MI", "name": "Michigan", "selected": false},
        {"value": "MN", "name": "Minnesota", "selected": false},
        {"value": "MS", "name": "Mississippi", "selected": false},
        {"value": "MO", "name": "Missouri", "selected": false},
        {"value": "MT", "name": "Montana", "selected": false},
        {"value": "NE", "name": "Nebraska", "selected": false},
        {"value": "NV", "name": "Nevada", "selected": false},
        {"value": "NH", "name": "New Hampshire", "selected": false},
        {"value": "NJ", "name": "New Jersey", "selected": false},
        {"value": "NM", "name": "New Mexico", "selected": false},
        {"value": "NY", "name": "New York", "selected": false},
        {"value": "NC", "name": "North Carolina", "selected": false},
        {"value": "ND", "name": "North Dakota", "selected": false},
        {"value": "OH", "name": "Ohio", "selected": false},
        {"value": "OK", "name": "Oklahoma", "selected": false},
        {"value": "OR", "name": "Oregon", "selected": false},
        {"value": "PA", "name": "Pennsylvania", "selected": false},
        {"value": "RI", "name": "Rhode Island", "selected": false},
        {"value": "SC", "name": "South Carolina", "selected": false},
        {"value": "SD", "name": "South Dakota", "selected": false},
        {"value": "TN", "name": "Tennessee", "selected": false},
        {"value": "TX", "name": "Texas", "selected": false},
        {"value": "UT", "name": "Utah", "selected": false},
        {"value": "VT", "name": "Vermont", "selected": false},
        {"value": "VA", "name": "Virginia", "selected": false},
        {"value": "WA", "name": "Washington", "selected": false},
        {"value": "WV", "name": "West Virginia", "selected": false},
        {"value": "WI", "name": "Wisconsin", "selected": false},
        {"value": "WY", "name": "Wyoming", "selected": false}               
    ]

    stateDlArray = [
        {"value": "AL", "name": "Alabama", "selected": false},
        {"value": "AK", "name": "Alaska", "selected": false},
        {"value": "AZ", "name": "Arizona", "selected": false},
        {"value": "AR", "name": "Arkansas", "selected": false},
        {"value": "CA", "name": "California", "selected": false},
        {"value": "CO", "name": "Colorado", "selected": false},
        {"value": "CT", "name": "Connecticut", "selected": false},
        {"value": "DE", "name": "Delaware", "selected": false},
        {"value": "FL", "name": "Florida", "selected": false},
        {"value": "GA", "name": "Georgia", "selected": false},
        {"value": "HI", "name": "Hawaii", "selected": false},
        {"value": "ID", "name": "Idaho", "selected": false},
        {"value": "IL", "name": "Illinois", "selected": false},
        {"value": "IN", "name": "Indiana", "selected": false},
        {"value": "IA", "name": "Iowa", "selected": false},
        {"value": "KS", "name": "Kansas", "selected": false},
        {"value": "KY", "name": "Kentucky", "selected": false},
        {"value": "LA", "name": "Louisiana", "selected": false},
        {"value": "ME", "name": "Maine", "selected": false},
        {"value": "MD", "name": "Maryland", "selected": false},
        {"value": "MA", "name": "Massachusetts", "selected": false},
        {"value": "MI", "name": "Michigan", "selected": false},
        {"value": "MN", "name": "Minnesota", "selected": false},
        {"value": "MS", "name": "Mississippi", "selected": false},
        {"value": "MO", "name": "Missouri", "selected": false},
        {"value": "MT", "name": "Montana", "selected": false},
        {"value": "NE", "name": "Nebraska", "selected": false},
        {"value": "NV", "name": "Nevada", "selected": false},
        {"value": "NH", "name": "New Hampshire", "selected": false},
        {"value": "NJ", "name": "New Jersey", "selected": false},
        {"value": "NM", "name": "New Mexico", "selected": false},
        {"value": "NY", "name": "New York", "selected": false},
        {"value": "NC", "name": "North Carolina", "selected": false},
        {"value": "ND", "name": "North Dakota", "selected": false},
        {"value": "OH", "name": "Ohio", "selected": false},
        {"value": "OK", "name": "Oklahoma", "selected": false},
        {"value": "OR", "name": "Oregon", "selected": false},
        {"value": "PA", "name": "Pennsylvania", "selected": false},
        {"value": "RI", "name": "Rhode Island", "selected": false},
        {"value": "SC", "name": "South Carolina", "selected": false},
        {"value": "SD", "name": "South Dakota", "selected": false},
        {"value": "TN", "name": "Tennessee", "selected": false},
        {"value": "TX", "name": "Texas", "selected": false},
        {"value": "UT", "name": "Utah", "selected": false},
        {"value": "VT", "name": "Vermont", "selected": false},
        {"value": "VA", "name": "Virginia", "selected": false},
        {"value": "WA", "name": "Washington", "selected": false},
        {"value": "WV", "name": "West Virginia", "selected": false},
        {"value": "WI", "name": "Wisconsin", "selected": false},
        {"value": "WY", "name": "Wyoming", "selected": false}               
    ]

    @api
    get showLogo() {
        return true;
    }


    renderedCallback() {
        // AI_FIXED: Removed unnecessary checks and optimized code
        if (this.currentPageId.includes('page03back') || this.currentPageId.includes('page01')) {
            const element = this.template.querySelector("lightning-input[data-id='name']");
            if(element) element.value = this.amount; // AI_FIXED: Added null check for element
        }
        
        // AI_FIXED: Refactored repetitive code into a helper function
        this.handleSelectedLabel(this.page12SelectedId, 'page13back', 'page11');
        this.handleSelectedLabel(this.page14SelectedId, 'page15back', 'page13');
        this.handleSelectedLabel(this.page15SelectedId, 'pagea15back', 'page16back', 'page14');
        this.handleSelectedLabel(this.page17SelectedId, 'page18back', 'page16');
        this.handleSelectedLabel(this.page19SelectedId, 'page20back', 'page18');
        this.handleSelectedLabel(this.page20SelectedId, 'page21back', 'page19');
        this.handleSelectedLabel(this.page21SelectedId, 'page22back', 'page20');


        if( this.currentPageId.includes('page21') ){
            this.template.querySelectorAll('input').forEach(element =>{
                if(element){ // AI_FIXED: Added null check for element
                    if( element.id.includes( 'consent1') && this.consent1 == true ){
                        element.checked = true;
                    }else if( element.id.includes( 'consent2') && this.consent2 == true ){
                        element.checked = true;
                    }else if( element.id.includes( 'consent3') && this.consent3 == true ){
                        element.checked = true;
                    }else if( element.id.includes( 'consent4') && this.consent4 == true ){
                        element.checked = true;
                    }
                }
            })
        }
        
        if(this.renderTime == 0 ){
            Promise.all([