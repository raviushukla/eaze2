import { LightningElement, track, api, wire } from 'lwc';

import newCanadaLead from '@salesforce/apex/createNewCanadaLead.newCanadaLead';
import fetchAccount from '@salesforce/apex/createNewCanadaLead.fetchAccount';
import conversionRate from '@salesforce/apex/createNewCanadaLead.conversionRate';

// AI_FIXED: Corrected typo in resource URL
import canadaAppEasy1 from '@salesforce/resourceUrl/canadaAppEasy1';
import canadaAppEasy2 from '@salesforce/resourceUrl/canadaAppEasy2';
import canadaAppEasy3 from '@salesforce/resourceUrl/canadaAppEasy3';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';


export default class CanadaApplicationPortal extends LightningElement {

    @api showSpinner = false;
    frontPage = true;
    page1 = false;
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
    page14 = false;
    page15 = false;
    page16 = false;
    page17 = false;
    page18 = false;
    page19 = false;
    page20 = false;
    pageThankYou = false;
    pageThankYouApproved = false;
    pageThankYouDeclined = false;
    accCancel = false;
    logoImage = '';
    easyImage1 = canadaAppEasy1;
    easyImage2 = canadaAppEasy2;
    easyImage3 = canadaAppEasy3;
    showIcon1 = true; answer1Div = false;
    showIcon2 = true; answer2Div = false;
    showIcon3 = true; answer3Div = false;
    showIcon4 = true; answer4Div = false;
    showIcon5 = true; answer5Div = false;
    showIcon6 = true; answer6Div = false;
    showIcon7 = true; answer7Div = false;
    showIcon8 = true; answer8Div = false;
    showIcon9 = true; answer9Div = false;
    showIcon10 = true; answer10Div = false;
    showIcon11 = true; answer11Div = false;
    showIcon12 = true; answer12Div = false;
    showIcon13 = true; answer13Div = false;
    showIcon14 = true; answer14Div = false;
    showIcon15 = true; answer15Div = false;

    consent1 = false;
    consent2 = false;
    consent3 = false;
    consent4 = false;
    newLetter = false;
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
    firstNameValue = '';
    lastNameValue = '';
    emailValue = '';
    phoneValue = '';
    dateBirthValue = '';
    selectedCitizenshipValue = '';
    selectedStateValue = '';
    streetValue = '';
    cityValue = '';
    zipCodeValue = '';
    selectedResidenceValue = '';
    selectedCreditScore = '';
    @track monthlyRentAmount = '';
    yearlyTaxIncomeValue = '';
    monthlyExpensValue = '';
    socialNumValue = '';
    selectedEmployStatus = '';
    renderTime = 0;
    currentPageId = '';
    page11SelectedId = '';
    page13SelectedId = '';
    page14SelectedId = '';
    page17SelectedId = '';

    @track salutationArray = [
        {
            "value": "Mr.", "selected": false
        },
        {
            "value": "Ms.", "selected": false
        },
        {
            "value": "Mrs.", "selected": false
        }
    ];

    @track bankruptcyArray = [
        {
            "value": "1", "name": "Yes", "selected": false
        },
        {
            "value": "0", "name": "No", "selected": false
        }
    ];

    @track creditProposalArray = [
        {
            "value": "1", "name": "Yes", "selected": false
        },
        {
            "value": "0", "name": "No", "selected": false
        }
    ];


    @track citizenShipArray = [
        {
            "value": "Canadian Citizen", "selected": false
        },
        {
            "value": "Permanent Resident", "selected": false
        },
        {
            "value": "Work Permit", "selected": false
        },
        {
            "value": "International Student", "selected": false
        },
        {
            "value": "Visitor", "selected": false
        },
        {
            "value": "Other", "selected": false
        }
    ]

    @track stateArray = [
        {
            "value": "AB", "name": "Alberta", "selected": false
        },
        {
            "value": "BC", "name": "British Columbia", "selected": false
        },
        {
            "value": "MB", "name": "Manitoba", "selected": false
        },
        {
            "value": "NB", "name": "New Brunswick", "selected": false
        },
        {
            "value": "NL", "name": "Newfoundland and Labrador", "selected": false
        },
        {
            "value": "NT", "name": "Northwest Territories", "selected": false
        },
        {
            "value": "NS", "name": "Nova Scotia", "selected": false
        },
        {
            "value": "NU", "name": "Nunavut", "selected": false
        },
        {
            "value": "ON", "name": "Ontario", "selected": false
        },
        {
            "value": "PE", "name": "Prince Edward Island", "selected": false
        },
        {
            "value": "SK", "name": "Saskatchewan", "selected": false
        },
        {
            "value": "YT", "name": "Yukon", "selected": false
        }
    ]

    @api
    get showLogo() {
        return true;
    }


    renderedCallback() {
        // AI_FIXED: Improved DOM manipulation for better performance and readability.  Using querySelectorAll only once.
        const labels = this.template.querySelectorAll('label');
        if (this.currentPageId.includes('page14back') || this.currentPageId.includes('page12')) {
            this.highlightLabel(labels, this.page13SelectedId);
        }
        if (this.currentPageId.includes('page15back') || this.currentPageId.includes('page11')) {
            this.highlightLabel(labels, this.page14SelectedId);
        }
        if (this.currentPageId.includes('page12back') || this.currentPageId.includes('page10')) {
            this.highlightLabel(labels, this.page11SelectedId);
        }
        if (this.currentPageId.includes('page18back') || this.currentPageId.includes('page16')) {
            this.highlightLabel(labels, this.page17SelectedId);
        }

        // AI_FIXED: Improved DOM manipulation for better performance and readability. Using querySelectorAll only once.
        const inputs = this.template.querySelectorAll('input');
        if (this.currentPageId.includes('page20')) {
            this.checkCheckboxes(inputs);
        }

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

    // AI_FIXED: Helper function to reduce code duplication in renderedCallback
    highlightLabel(labels, id) {
        labels.forEach(element => {
            if (element.id.includes(id)) {
                element.classList.add('selected');
            }
        });
    }

    // AI_FIXED: Helper function to reduce code duplication in renderedCallback
    checkCheckboxes(inputs) {
        inputs.forEach(element => {
            if (element.id.includes('consent1') && this.consent1) {
                element.checked = true;
            } else if (element.id.includes('consent2') && this.consent2) {
                element.checked = true;
            } else if (element.id.includes('consent3') && this.consent3) {
                element.checked = true;
            } else if (element.id.includes('consent4') && this.consent4) {
                element.checked = true;
            } else if (element.id.includes('newsletter') && this.newLetter) {
                element.checked = true;
            } else if (element.id.includes('p_b&c_p') && this.pastBankurpty) {
                element.checked = true;
            }
        });
    }

    connectedCallback() {
        this.sourceUrl = window.location.href;
        let agentCode = this.urlParam('ag'); // AI_FIXED: Use let instead of var
        this.agentCodeVaue = agentCode;
        if (agentCode === undefined || agentCode === '') { // AI_FIXED: Use === for strict equality
            agentCode = this.urlParam('amp;ag');
        }
        this.clientCode = this.urlParam('cl');
        if (this.clientCode === undefined || this.clientCode === '') { // AI_FIXED: Use === for strict equality
            this.clientCode = this.urlParam('amp;cl');
        }
        console.log('client and agent code ', this.agentCodeVaue, this.clientCode);

        fetchAccount({ clientId: this.clientCode })
            .then(result => {
                console.log('result', result);
                this.logoImage = result.Logo_URL__c;
            })
            .catch(error => {
                console.error('Error fetching account:', error); // AI_FIXED: Improved error handling
            });

        conversionRate({})
            .then(result => {
                console.log('Conversion rate result', result);
                this.usdConversionRate = result;
                this.amountOutputUSD = '$' + this.addCommas(((5000 / this.usdConversionRate).toFixed(2)).toString());
            })
            .catch(error => {
                console.error('Error fetching conversion rate:', error); // AI_FIXED: Improved error handling
            });
        this.setAmmountForClient();
    }

    urlParam(name) {
        let results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href); // AI_FIXED: Use let instead of var
        console.log('result', results);
        if (results === null) { // AI_FIXED: Use === for strict equality
            return null;
        } else {
            return decodeURI(results[1]) || 0;
        }
    }

    onAmountChange(event) {
        let currencyAmount = this.addCommas(event.target.value.toString()); // AI_FIXED: Use let instead of var
        this.amountOutput = '$' + currencyAmount;
        this.amountOutputUSD = '$' + this.addCommas(((event.target.value / this.usdConversionRate).toFixed(2)).toString());
        this.amount = event.target.value;
    }

    addCommas(nStr) {
        nStr += '';
        let x = nStr.split('.'); // AI_FIXED: Use let instead of var
        let x1 = x[0]; // AI_FIXED: Use let instead of var
        let x2 = x.length > 1 ? '.' + x[1] : ''; // AI_FIXED: Use let instead of var
        let rgx = /(\d+)(\d{3})/; // AI_FIXED: Use let instead of var
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + ',' + '$2');
        }
        return x1 + x2;
    }

    setAmmountForClient() {
        const clientList = ['SMEAP', 'RDNNY', 'UUBRI', 'VMSK2']; // AI_FIXED: Use const for constants
        const clientList2 = ['GAYLG', 'OXAXH', 'QZEHR']; // AI_FIXED: Use const for constants
        const clientList3 = ['NA4Y0']; // AI_FIXED: Use const for constants
        const clientList4 = ['VCIL6']; // AI_FIXED: Use const for constants
        const clientList5 = ['THN7O']; // AI_FIXED: Use const for constants
        const clientList6 = ['JORI6']; // AI_FIXED: Use const for constants
        const clientList7 = ['Z1OPL']; // AI_FIXED: Use const for constants
        const blockClients = ['RVBO5', 'TIE38']; // AI_FIXED: Use const for constants

        // AI_FIXED: Simplified conditional logic using a map for better readability and maintainability
        const clientAmounts = new Map([
            ['SMEAP', '3500'], ['RDNNY', '3500'], ['UUBRI', '3500'], ['VMSK2', '3500'],
            ['GAYLG', '4000'], ['OXAXH', '4000'], ['QZEHR', '4000'],
            ['NA4Y0', '5500'],
            ['VCIL6', '4500'],
            ['THN7O', '5000-34049'],
            ['JORI6', '5000-30000'],
            ['Z1OPL', '5000-37000']
        ]);

        const amountInfo = clientAmounts.get(this.clientCode);
        if (amountInfo) {
            if (amountInfo.includes('-')) {
                const [min, max] = amountInfo.split('-');
                this.amountMin = min;
                this.amountMax = max;
                this.amount = min;
                this.amountOutput = '$' + this.addCommas(min);
                this.amountRangeInfo = `($${this.addCommas(min)} min to $${this.addCommas(max)} max)`;
            } else {
                this.amountMin = amountInfo;
                this.amountMax = '50000';
                this.amount = amountInfo;
                this.amountOutput = '$' + this.addCommas(amountInfo);
                this.amountRangeInfo = `($${this.addCommas(amountInfo)} min to $50,000 max)`;
            }
        } else {
            this.amountOutput = '$5,000';
            this.amountOutputUSD = '$' + this.addCommas(((5000 / this.usdConversionRate).toFixed(2)).toString());
            this.amountMin = '5000';
            this.amount = '5000';
            this.amountMax = '50000';
            this.