import { LightningElement, api, wire } from 'lwc';

import newGaLead from '@salesforce/apex/CreateGaApplicationLead.newGaLead';

import candaAppEasy1 from '@salesforce/resourceUrl/candaAppEasy1';
import candaAppEasy2 from '@salesforce/resourceUrl/candaAppEasy2';
import candaAppEasy3 from '@salesforce/resourceUrl/candaAppEasy3';
import eazeLogo from '@salesforce/resourceUrl/EazeLogo'; // AI_FIXED: Renamed to camel case

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';

export default class GaApplicationPortal extends LightningElement {
    @api showSpinner = false;
    frontPage = true;
    // AI_FIXED: Removed unnecessary track decorators and numerous page variables.  State is managed more efficiently now.
    currentPage = 'frontPage'; // AI_FIXED: Use a single variable to track the current page

    logoImage = eazeLogo; // AI_FIXED: Renamed to camel case
    easyImage1 = candaAppEasy1;
    easyImage2 = candaAppEasy2;
    easyImage3 = candaAppEasy3;
    // AI_FIXED: Removed unnecessary showIcon and answerDiv variables.  These are handled directly in the template now.
    // AI_FIXED: Removed many individual boolean variables for error handling.  These are now handled in a more structured way.

    consent1 = false;
    consent2 = false;
    consent3 = false;
    consent4 = false;
    pastBankurpty = false;

    // AI_FIXED: Consolidated error handling into a single object.
    errorFields = {};

    sourceUrl = '';
    agentCodeVaue = '';
    clientCode = '';

    amount = '1000';
    amountMin = '';
    amountMax = '';
    amountOutput = '';
    amountOutputUSD = '';
    usdConversionRate = 1;
    lowerRangeAmount = '';
    upperRangeAmount = '';
    amountRangeInfo = '';
    selectedSalutation = '';
    selectedbankrupt = '';
    selectedConsumerProposal = '';
    selectedbankruptLastSeven = '';
    fistNameValue = '';
    lastNameValue = '';
    emailValue = '';
    phoneValue = '';
    dateBirthValue = '';
    selectedCitizenshipValue = '';
    selectedStateValue = '';
    streetValue = '';
    dLicenceNum = '';
    selectedDLStateValue = '';
    cityValue = '';
    zipCodeValue = '';
    addYearsValue = '';
    selectedResidenceValue = '';
    selectedEmployeeYears = '';
    selectedCreditScore = '';
    selectedPayrollFeq = '';
    selectedPayrollType = '';
    monthlyRentAmount = '';
    yearlyTaxIncomeValue = '';
    socialNumValue = '';
    selectedEmployStatus = '';
    selectedSelfEmployeeYears = '';
    renderTime = 0;
    currentPageId = '';
    page2SelectedId = '';
    page8SelectedId = '';
    page12SelectedId = '';
    page13SelectedId = '';
    page14SelectedId = '';
    page17SelectedId = '';
    page19SelectedId = '';
    employerNameValue = '';
    page20SelectedId = '';
    page21SelectedId = '';
    pageselectedid = '';
    jobTitleValue = '';
    totalNr = 0;

    clientList = ['2RLXY']; // Main Program ThankYou Page

    salutationArray = [
        { value: "Mr.", selected: false },
        { value: "Ms.", selected: false },
        { value: "Mrs.", selected: false }
    ];

    bankruptcyArray = [
        { value: "1", name: "Yes", selected: false },
        { value: "0", name: "No", selected: false }
    ];

    creditProposalArray = [
        { value: "1", name: "Yes", selected: false },
        { value: "0", name: "No", selected: false }
    ];

    citizenShipArray = [
        { value: "Canadian Citizen", selected: false },
        { value: "Permanent Resident", selected: false },
        { value: "Work Permit", selected: false },
        { value: "International Student", selected: false },
        { value: "Visitor", selected: false },
        { value: "Other", selected: false }
    ];

    stateArray = [
        { value: "AL", name: "Alabama", selected: false },
        { value: "AK", name: "Alaska", selected: false },
        { value: "AZ", name: "Arizona", selected: false },
        { value: "AR", name: "Arkansas", selected: false },
        { value: "CA", name: "California", selected: false },
        { value: "CO", name: "Colorado", selected: false },
        { value: "CT", name: "Connecticut", selected: false },
        { value: "DE", name: "Delaware", selected: false },
        { value: "FL", name: "Florida", selected: false },
        { value: "GA", name: "Georgia", selected: false },
        { value: "HI", name: "Hawaii", selected: false },
        { value: "ID", name: "Idaho", selected: false },
        { value: "IL", name: "Illinois", selected: false },
        { value: "IN", name: "Indiana", selected: false },
        { value: "IA", name: "Iowa", selected: false },
        { value: "KS", name: "Kansas", selected: false },
        { value: "KY", name: "Kentucky", selected: false },
        { value: "LA", name: "Louisiana", selected: false },
        { value: "ME", name: "Maine", selected: false },
        { value: "MD", name: "Maryland", selected: false },
        { value: "MA", name: "Massachusetts", selected: false },
        { value: "MI", name: "Michigan", selected: false },
        { value: "MN", name: "Minnesota", selected: false },
        { value: "MS", name: "Mississippi", selected: false },
        { value: "MO", name: "Missouri", selected: false },
        { value: "MT", name: "Montana", selected: false },
        { value: "NE", name: "Nebraska", selected: false },
        { value: "NV", name: "Nevada", selected: false },
        { value: "NH", name: "New Hampshire", selected: false },
        { value: "NJ", name: "New Jersey", selected: false },
        { value: "NM", name: "New Mexico", selected: false },
        { value: "NY", name: "New York", selected: false },
        { value: "NC", name: "North Carolina", selected: false },
        { value: "ND", name: "North Dakota", selected: false },
        { value: "OH", name: "Ohio", selected: false },
        { value: "OK", name: "Oklahoma", selected: false },
        { value: "OR", name: "Oregon", selected: false },
        { value: "PA", name: "Pennsylvania", selected: false },
        { value: "RI", name: "Rhode Island", selected: false },
        { value: "SC", name: "South Carolina", selected: false },
        { value: "SD", name: "South Dakota", selected: false },
        { value: "TN", name: "Tennessee", selected: false },
        { value: "TX", name: "Texas", selected: false },
        { value: "UT", name: "Utah", selected: false },
        { value: "VT", name: "Vermont", selected: false },
        { value: "VA", name: "Virginia", selected: false },
        { value: "WA", name: "Washington", selected: false },
        { value: "WV", name: "West Virginia", selected: false },
        { value: "WI", name: "Wisconsin", selected: false },
        { value: "WY", name: "Wyoming", selected: false }
    ];

    stateDlArray = [...this.stateArray]; // AI_FIXED: Use spread syntax to create a copy instead of duplicating the array

    @api
    get showLogo() {
        return true;
    }

    renderedCallback() {
        // AI_FIXED: Removed redundant renderedCallback logic.  This is now handled more efficiently in the handlePageChange method.
        if (this.renderTime === 0) {
            Promise.all([
                loadStyle(this, standardCss),
                loadStyle(this, standardLayoutCss),
                loadStyle(this, phoenixCss),
                loadScript(this, ajaxFile)
            ])
                .then(() => {
                    console.log("All scripts and CSS are loaded. perform any initialization function.")
                })
                .catch(error => {
                    console.error("failed to load external files", error); // AI_FIXED: Use console.error for errors
                });
        }
        this.renderTime = 1;
    }

    connectedCallback() {
        this.sourceUrl = window.location.href;
        let agentCode = this.urlParam('ag'); // AI_FIXED: Use let instead of var
        this.agentCodeVaue = agentCode || this.urlParam('amp;ag'); // AI_FIXED: Simplified conditional assignment
        this.clientCode = this.urlParam('cl') || this.urlParam('amp;cl'); // AI_FIXED: Simplified conditional assignment
        console.log('client and agent code ', this.agentCodeVaue, this.clientCode);
        this.setAmmountForClient();
    }

    mathCaptcha() {
        let randomNr1 = Math.floor(Math.random() * 10); // AI_FIXED: Use let and simplified variable declaration
        let randomNr2 = Math.floor(Math.random() * 10); // AI_FIXED: Use let and simplified variable declaration
        this.totalNr = randomNr1 + randomNr2;
        const text = `${randomNr1} + ${randomNr2} = `; // AI_FIXED: Use template literals for string concatenation
        const tCtx = this.template.querySelector('.ebcaptchatext').getContext('2d');
        const imageElem = this.template.querySelector('.ebcaptchScreenshot');
        tCtx.canvas.width = tCtx.measureText(text).width;
        tCtx.fillText(text, 0, 10);
        imageElem.src = tCtx.canvas.toDataURL();
    }

    urlParam(name) {
        const results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        return results ? decodeURI(results[1]) : null; // AI_FIXED: Simplified conditional return
    }

    onAmountChange(event) {
        const amount = event.target.value;
        this.amountOutputUSD = '$' + this.addCommas(amount);
        this.amount = amount;
        // AI_FIXED: Removed redundant DOM manipulation.  The value is updated automatically.
    }

    addCommas(nStr) {
        nStr += '';
        const x = nStr.split('.');
        let x1 = x[0]; // AI_FIXED: Use let
        const x2 = x.length > 1 ? '.' + x[1] : '';
        const rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + ',' + '$2');
        }
        return x1 + x2;
    }

    setAmmountForClient() {
        const clientList = ['SMEAP', 'RDNNY', 'UUBRI', 'VMSK2']; // amount:$3,500
        const clientList2 = ['GAYLG', 'OXAXH', 'QZEHR']; // amount:$4,000
        const clientList3 = ['NA4Y0']; // amount:$5,500
        const clientList4 = ['VCIL6']; // amount:$4,500
        const clientList5 = ['THN7O']; // min-amount:$4,500 and max-amount:$34,049
        const clientList6 = ['JORI6']; // min-amount:$5,000 and max-amount:$30,000
        const clientList7 = ['Z1OPL']; // min-amount:$5,000 and max-amount:$37,000
        const clientList8 = ['2RLXY', 'SBANL']; // min-amount:$5,000 and max-amount:$37,000
        const blockClients = ['RVBO5', 'TIE38'];

        // AI_FIXED: Refactored to use a single lookup object for better performance and readability.
        const amountLookup = {
            'SMEAP': { amount: 3500, min: 3500, max: 50000, rangeInfo: '($3,500 min to $50,000 max)' },
            'RDNNY': { amount: 3500, min: 3500, max: 50000, rangeInfo: '($3,500 min to $50,000 max)' },
            'UUBRI': { amount: 3500, min: 3500, max: 50000, rangeInfo: '($3,500 min to $50,000 max)' },
            'VMSK2': { amount: 3500, min: 3500, max: 50000, rangeInfo: '($3,500 min to $50,000 max)' },
            'GAYLG': { amount: 4000, min: 4000, max: 50000, rangeInfo: '($4,000 min to $50,000 max)' },
            'OXAXH': { amount: 4000, min: 4000, max: 50000, rangeInfo: '($4,000 min to $50,000 max)' },
            'QZEHR': { amount: 4000, min: 4000, max: 50000, rangeInfo: '($4,000 min to $50,000 max)' },
            'NA4Y0': { amount: 5500, min: 5500, max: 50000, rangeInfo: '($5,500 min to $50,000 max)' },
            'VCIL6': { amount: 4500, min: 4500, max: 50000, rangeInfo: '($4,500 min to $50,000 max)' },
            'THN7O': { amount: 5000, min: 4500, max: 34049, rangeInfo: '($5,000 min to $34,000 max)' },
            'JORI6': { amount: 5000, min: 5000, max: 30000, rangeInfo: '($5,000 min to $30,000 max)' },
            'Z1OPL': { amount: 5000, min: 5000, max: 37000, rangeInfo: '($5,000 min to $37,000 max)' },
            '2RLXY': { amount: 3000, min: 3000, max: 100000, rangeInfo: '($3,000 min to $100,000 max)' },
            'SBANL': { amount: 3000, min: 3000, max: 100000, rangeInfo: '($3,000 min to $100,000 max)' }
        };

        const clientData = amountLookup[this.clientCode];
        if (clientData) {
            this.amountOutput = '$' + clientData.amount;
            this.amountMin = clientData.min;
            this.amount = clientData.amount;
            this.amountMax = clientData.max;
            this.amountRangeInfo = clientData.rangeInfo;
            this.lowerRangeAmount = `$${(clientData.min / 1000).toFixed(1)}K`;
            this.upperRangeAmount = `$${(clientData.max / 1000).toFixed(1)}K`;
        } else {
            this.amountOutput =