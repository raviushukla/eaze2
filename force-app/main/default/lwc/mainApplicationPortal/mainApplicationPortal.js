import { LightningElement , api, wire, track} from 'lwc';

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
    page1a = false
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
    //showLogo = false;
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

    sourceUrl = ''
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
    @track monthlyRentAmount = '';
    yearlyTaxIncomeValue = '';
    socialNumValue = '';
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
    employerNameValue = '';
    page20SelectedId = '';
    page21SelectedId = '';
    pageselectedid = '';
    jobTitleValue = '';
    totalNr = 0;

    removePreQual = false;

    clientList = ['2RLXY']; // Main Program ThankYou Page

    @track salutationArray = [
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

    @track bankruptcyArray = [
        {
            "value":"1", "name":"Yes","selected": false
        },
        {
            "value":"0", "name":"No","selected": false
        }
    ];

    @track creditProposalArray = [
        {
            "value":"1", "name":"Yes","selected": false
        },
        {
            "value":"0", "name":"No","selected": false
        }
    ];


    @track citizenShipArray = [
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

    @track stateArray = [
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

    @track stateDlArray = [
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
        console.log('render hit');

        if( ( this.currentPageId.includes('page03back') || this.currentPageId.includes('page01') && (this.amount != null || this.amount !='') ) ){
            const element = this.template.querySelector("lightning-input[data-id='name']");
            element.value = this.amount;
        }
        
        if( ( this.currentPageId.includes('page13back') || this.currentPageId.includes('page11') ) && this.page12SelectedId != '' ){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.page12SelectedId) ){
                    element.classList.add('selected');
                    console.log('class is add', element.classList )
                }
            });
        }

        if( ( this.currentPageId.includes('page15back') || this.currentPageId.includes('page13') ) && this.page14SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.page14SelectedId) ){
                    element.classList.add('selected');
                    console.log('class is add', element.classList )
                }
            });
        }

        if((this.currentPageId.includes('pagea15back') || this.currentPageId.includes('page16back') || this.currentPageId.includes('page14') ) && this.page15SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                    console.log('element id', element.id);
                    if( element.id.includes(this.page15SelectedId) ){
                        element.classList.add('selected');
                        console.log('class is add', element.classList )
                    } 
            })
        }

        if(( this.currentPageId.includes('page20back') || this.currentPageId.includes('page18') ) && this.page19SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                    console.log('element id', element.id);
                    if( element.id.includes(this.page19SelectedId) ){
                        element.classList.add('selected');
                        console.log('class is add', element.classList )
                    } 
            })
        }

        if(( this.currentPageId.includes('page21back') || this.currentPageId.includes('page19') ) && this.page20SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                    console.log('element id', element.id);
                    if( element.id.includes(this.page20SelectedId) ){
                        element.classList.add('selected');
                        console.log('class is add', element.classList )
                    } 
            })
        }

        if(( this.currentPageId.includes('page22back') || this.currentPageId.includes('page20') ) && this.page21SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                    console.log('element id', element.id);
                    if( element.id.includes(this.page21SelectedId) ){
                        element.classList.add('selected');
                        console.log('class is add', element.classList )
                    } 
            })
        }

        if( this.currentPageId.includes('page21') ){
            this.template.querySelectorAll('input').forEach(element =>{
                    if( element.id.includes( 'consent1') && this.consent1 == true ){
                        element.checked = true;
                        console.log('element id', element.id);
                    }else if( element.id.includes( 'consent2') && this.consent2 == true ){
                        element.checked = true;
                        console.log('element id', element.id);
                    }else if( element.id.includes( 'consent3') && this.consent3 == true ){
                        element.checked = true;
                        console.log('element id', element.id);
                    }else if( element.id.includes( 'consent4') && this.consent4 == true ){
                        element.checked = true;
                        console.log('element id', element.id);
                    }
            })
        }
        
        if(( this.currentPageId.includes('page18back') || this.currentPageId.includes('page16') ) && this.page17SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                    console.log('element id', element.id);
                    if( element.id.includes(this.page17SelectedId) ){
                        element.classList.add('selected');
                        console.log('class is add', element.classList )
                    } 
            })
        }
        
        
        if(this.renderTime == 0 ){
            Promise.all([
                loadStyle(this, standardCss),
                loadStyle(this, standardLayoutCss),
                loadStyle(this, phoenixCss ),
                loadScript(this, ajaxFile )
            ])
                .then(() => {
                    console.log("All scripts and CSS are loaded. perform any initialization function.")
                })
                .catch(error => {
                    console.log("failed to load external files", error );
                });
        }
        this.renderTime = 1;
    }

    connectedCallback() {
        this.sourceUrl = window.location.href;
        var agentCode = this.urlParam('ag');
        this.agentCodeVaue = agentCode;
        if(agentCode == undefined || agentCode == ''){
            agentCode = this.urlParam('amp;ag');
        }
        this.clientCode = this.urlParam('cl');
        if(this.clientCode == undefined || this.clientCode == ''){
            this.clientCode = this.urlParam('amp;cl');
        }
        console.log('client and agent code ', this.agentCodeVaue, this.clientCode );
        
        //this.setAmmountForClient();
        this.getLoanAmount();
    }

    getLoanAmount(){
        getLoanAmount({ clientCode : this.clientCode, agentCode : this.agentCodeVaue })
            .then((result) => {
                const minString = result.minAmt.toLocaleString('en-US', {
                    style: 'currency',
                    currency: 'USD',
                  });
                const maxString = result.maxAmt.toLocaleString('en-US', {
                style: 'currency',
                currency: 'USD',
                });  
                this.manualAmount = result.minAmt;
                this.amountOutput = minString;
                this.amountMin= result.minAmt.toString();
                this.amount = result.minAmt.toString();
                this.amountMax = result.maxAmt.toString();
                this.lowerRangeAmount = '$'+(result.minAmt/1000).toString()+'K';
                this.upperRangeAmount = '$'+(result.maxAmt/1000).toString()+'K';
                this.amountRangeInfo = '('+minString+' min to '+maxString+')';
                this.removePreQual = result.accPreQualRemoved ;
            }).catch((error) =>{
                console.log('having error', error );
            });
            
    }
    //-- captcha code start----
    mathCaptcha(){
        var randomNr1 = 0; 
        var randomNr2 = 0;
        randomNr1 = Math.floor(Math.random()*10);
        randomNr2 = Math.floor(Math.random()*10);
        this.totalNr = randomNr1 + randomNr2;
        var texti = randomNr1+" + "+randomNr2+" = ";
        var tCtx = this.template.querySelector('.ebcaptchatext').getContext('2d'),
            imageElem = this.template.querySelector('.ebcaptchScreenshot');
        tCtx.canvas.width = tCtx.measureText(texti).width;
        tCtx.fillText(texti, 0, 10);
        imageElem.src = tCtx.canvas.toDataURL();
    }

    urlParam(name){
        var results = new RegExp('[\?&]' + name + '=([^&#]*)').exec(window.location.href);
        console.log('result', results);
        if (results==null){
            return null;
        }
        else{
            return decodeURI(results[1]) || 0;
        }
    }

    /*Ammont section*/
    
    onAmountChange(event) {
        console.log('amount', event.target.value);
        var currencyAmount = this.addCommas(event.target.value.toString());
        this.amountOutput = '$' + currencyAmount;
        this.amount = event.target.value;
        const element = this.template.querySelector("lightning-input[data-id='name']");
        element.value = event.target.value;
    }   

    addCommas(nStr) {
        nStr += '';
        var x = nStr.split('.');
        var x1 = x[0];
        var x2 = x.length > 1 ? '.' + x[1] : '';
        var rgx = /(\d+)(\d{3})/;
        while (rgx.test(x1)) {
            x1 = x1.replace(rgx, '$1' + ',' + '$2');
        }
        return x1 + x2;
    }

    setAmmountForClient(){
        var clientList = ['SMEAP','RDNNY','UUBRI','VMSK2']; // amount:$3,500
        var clientList2 = ['GAYLG','OXAXH','QZEHR','WRZ9J','RNHDC']; // amount:$4,000
        var clientList3 = ['NA4Y0']; // amount:$5,500
        var clientList4 = ['VCIL6','SPUO9']; // amount:$4,500
        var clientList5 = ['THN7O']; // min-amount:$4,500 and max-amount:$13,500
        var clientList6 = ['JORI6']; // min-amount:$5,000 and max-amount:$30,000
        var clientList7 = ['Z1OPL']; // min-amount:$5,000 and max-amount:$37,000
        var clientList8 = ['DLK6H']; // min-amount:$5,000 and max-amount:$6,000
        var clientList9 = ['LSIPX']; // min-amount:$6,000
        var clientList10 = ['SBANL','16NBF'];	// min-amount:$3,000
        var blockClients = ['RVBO5','TIE38'];
        
        if(clientList.includes(this.clientCode)){
            this.manualAmount = 3500;
            this.amountOutput = '$3,500';
            this.amountMin = '3500';
            this.amount = '3500';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$3.5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($3,500 min to $50,000 max)';
        }
        else if(clientList2.includes(this.clientCode)){
            this.manualAmount = 4000;
            this.amountOutput = '$4,000';
            this.amountMin = '4000';
            this.amount = '4000';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$4K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($4,000 min to $50,000 max)';
        }
        else if(clientList3.includes(this.clientCode)){
            this.manualAmount = 5500;
            this.amountOutput = '$5,500';
            this.amountMin = '5500';
            this.amount = '5500';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$5.5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($5,500 min to $50,000 max)';
        }
        else if(clientList4.includes(this.clientCode)){
            this.manualAmount = 4500;
            this.amountOutput = '$4,500';
            this.amountMin = '4500';
            this.amount = '4500';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$4.5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($4,500 min to $50,000 max)';
        }
        else if(clientList5.includes(this.clientCode)){
            this.manualAmount = 5000;
            this.amountOutput = '$5,000';
            this.amountMin = '5000';// min
            this.amount = '5000';
            this.amountMax = '34049';// max
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$34K';
            this.amountRangeInfo = '($5,000 min to $34,000 max)';
        }
        else if(clientList6.includes(this.clientCode)){
            this.manualAmount = 5000;
            this.amountOutput = '$5,000';
            this.amountMin = '5000';//min
            this.amount = '5000';
            this.amountMax = '30000';//max
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$30K';
            this.amountRangeInfo = '($5,000 min to $30,000 max)';
        }
        else if(clientList7.includes(this.clientCode)){
            this.manualAmount = 5000;
            this.amountOutput = '$5,000';
            this.amountMin = '5000';//min
            this.amount = '5000';
            this.amountMax = '37000';//max
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$37K';
            this.amountRangeInfo = '($5,000 min to $37,000 max)';
        }
        else if(clientList8.includes(this.clientCode)){
            this.manualAmount = 5000;
            this.amountOutput = '$5,000';
            this.amountMin = '5000';//min
            this.amount = '5000';
            this.amountMax = '6000';//max
            this.lowerRangeAmount = '$3K';
            this.upperRangeAmount = '$6K';
            this.amountRangeInfo = '($3,000 min to $6,000 max)';
        }
        else if(clientList9.includes(this.clientCode)){
            this.manualAmount = 6000;
            this.amountOutput = '$6,000';
            this.amountMin = '6000';//min
            this.amount = '6000';
            this.amountMax = '100000';//max
            this.lowerRangeAmount = '$6K';
            this.upperRangeAmount = '$100K';
            this.amountRangeInfo = '($3,000 min to $100,000 max)';
        }
        else if(clientList10.includes(this.clientCode)){
            this.manualAmount = 3000;
            this.amountOutput = '$3,000';
            this.amountMin = '3000';//min
            this.amount = '3000';
            this.amountMax = '100000';//max
            this.lowerRangeAmount = '$3K';
            this.upperRangeAmount = '$100K';
            this.amountRangeInfo = '($3,000 min to $100,000 max)';
        }
        else{
            this.manualAmount = 5000;
            this.amountOutput = '$5,000';
            this.amountMin= '5000';
            this.amount = '5000';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($5,000 min to $50,000 max)';
        }
    }

    /*Name section*/
    selectSalutation(event){
        var vvv = this.salutationArray;
        for(var i =0; i < vvv.length; i++ ){
            if(vvv[i].value == event.target.value ){
                vvv[i].selected = true;
            }
        }
        console.log('event select hit');
        console.log('select value', event.target.value);
        this.selectedSalutation = event.target.value;
    }

    selectBankrupt(event){
        var vvv = this.bankruptcyArray;
        for(var i =0; i < vvv.length; i++ ){
            if(vvv[i].value == event.target.value ){
                vvv[i].selected = true;
            }
        }
        console.log('event select hit');
        console.log('select value', event.target.value);
        this.selectedbankruptLastSeven = event.target.value;
    }
    
    selectCreditProposal(event){
        var vvv = this.creditProposalArray;
        for(var i =0; i < vvv.length; i++ ){
            if(vvv[i].value == event.target.value ){
                vvv[i].selected = true;
            }
        }
        console.log('event select hit');
        console.log('select value', event.target.value);
        this.selectedConsumerProposal = event.target.value;
    }

    setEmployerName(event){
        this.employerNameValue = event.target.value;
        event.target.value.length > 0 ? this.employerNameError = false : this.employerNameError = false;
    }

    setJobTitle(event){
        this.jobTitleValue = event.target.value;
        event.target.value.length > 0 ? this.jobTitleError = false : this.jobTitleError = false;
    }

    validateFirstName(event){
        var letters = /^[A-Za-z]+$/;
        var val = event.target.value;
        this.fistNameValue = val;
        this.firstNameError = false;
    }

    validateLastName(event){
        var letters = /^[A-Za-z ]+$/;
        var val = event.target.value;
        this.lastNameValue = val;
        this.lastNameError = false;
    }

    /*email section*/

    setEmailValue(event){
        this.emailValue = event.target.value;
        this.validateEmail(event.target.value);

    }

    validateEmail(val){
        console.log('evn hit',val);

        if(this.emailValue == ''){
            this.enterEmailError = true;
            this.emailError = false;
            return false;
        }
        if (/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/.test(val)){
            console.log('no error ');
            this.emailError = false;
            this.enterEmailError = false;
            return true;
        }else{
            console.log('email error');
            this.enterEmailError = false;
            this.emailError = true;
            return false;
        }
    }

    /*phone section*/

    validatePhone(event){
        console.log('event occured');
        console.log('phone value', event.target.value, this.phoneValue);
        var val = event.target.value;
        this.phoneError = false;
        if( val.length > this.phoneValue.length ){
            console.log('dwf');
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

        this.phoneValue = val;
        event.target.value = val;
    }

    checkPhoneNumber(event){
        var val = event.target.value;
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
        if(val.length < 14 ){
            this.phoneError = true;
        }else {
            this.phoneError = false;
        }
    }

    /*BirthDate section*/

    setBirthDate(event){
        var val = event.target.value;
        console.log('date value', event.target.value);
        
        if( val.length == 10 ){
            if(!this.isValidDate(val)){
                this.dateBirthError = true;
            }else {
                this.dateBirthError = false;
            }
        }

        if( this.dateBirthValue.length < val.length ){
            var r = /(\D+)/g,
            mon = '',
            day = '',
            year = '';

            val = val.replace(r, '');
            mon = val.substr(0, 2);
            day = val.substr(2, 2);
            year = val.substr(4, 4);

            if(val.length < 2){
                val = mon;
            }else if(val.length > 1 && val.length < 4){
                val = mon + '/' + day;
            }else if( val.length > 3){
                val = mon + '/' + day + '/' + year;
            }
            console.log('format date', val );
        }

        this.dateBirthValue = val;
        event.target.value = val;
    }

    checkDateBirth(event){
        var val = event.target.value;
        console.log('date value', val);
        if( !this.isValidDate(val) ){
            this.dateBirthError = true;
        }else {
            this.dateBirthError = false;
        }
    }

    isValidDate(dateString){
        // First check for the pattern
        console.log('isvalid hit');
        const birthDate = new Date(dateString);
        if(!/^\d{1,2}\/\d{1,2}\/\d{4}$/.test(dateString))
            return false;

        // Parse the date parts to integers
        var parts = dateString.split("/");
        var day = parseInt(parts[1], 10);
        var month = parseInt(parts[0], 10);
        var year = parseInt(parts[2], 10);

        // Check the ranges of month and year
        if(year < 1916 || !this.is18YearsOrOlder(birthDate) || month == 0 || month > 12)
            return false;

        var monthLength = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ];

        // Adjust for leap years
        if(year % 400 == 0 || (year % 100 != 0 && year % 4 == 0))
            monthLength[1] = 29;

        // Check the range of the day
        return day > 0 && day <= monthLength[month - 1];
    }

    is18YearsOrOlder(date) {
        // Get the current date
        const currentDate = new Date();

        // Calculate the difference in years between the given date and the current date
        const age = currentDate.getFullYear() - date.getFullYear();
		console.log(age);
        // If the difference is less than 18, return false
        if (age < 18) {
          return false;
        }

        // If the difference is 18, check the months
        if (age === 18) {
          // If the given date's month is later than the current date's month, return false
          if (date.getMonth() > currentDate.getMonth()) {
            return false;
          }

          // If the given date's month is the same as the current date's month, check the day
          if (date.getMonth() === currentDate.getMonth()) {
            // If the given date's day is later than the current date's day, return false
            if (date.getDate() > currentDate.getDate()) {
              return false;
            }
          }
        }

        // If none of the above conditions are met, the person is 18 years or older
        return true;
      } 

    /*citizenshipsection*/  

    selectCitizenship(event){
        console.log('event hit', event.target.value);
        this.selectedCitizenshipValue = event.target.value;
        this.citizenShipError = false;
        for(var i = 0; i< this.citizenShipArray.length; i++ ){
            if( this.citizenShipArray[i].value == this.selectedCitizenshipValue ){
                this.citizenShipArray[i].selected = true;
            }
        }
    }

    /*address section*/

    selectState(event){
        console.log('selected state', event.target.value);
        this.selectedStateValue = event.target.value;
        for(var i = 0; i < this.stateArray.length; i++ ){
            if(this.stateArray[i].value == this.selectedStateValue ){
                this.stateArray[i].selected = true;
            }
        }
    }

    setStreeValue(eve){
        console.log('eve hit', eve.target.value );
        this.streetValue = eve.target.value;
    }
    
    setCityValue(eve){
        console.log('eve hit', eve.target.value);
        this.cityValue = eve.target.value;
    }

    setDLicenceNumValue(event){
        console.log('event hit', event.target.value );
        this.dLicenceNum = event.target.value;
    }

    selectDLState(event){
        console.log('selected state', event.target.value);
        this.selectedDLStateValue = event.target.value;
        for(var i = 0; i < this.stateDlArray.length; i++ ){
            if(this.stateDlArray[i].value == this.selectedStateValue ){
                this.stateDlArray[i].selected = true;
            }
        }
    }

    validateAddYears(event){
        var numbers = /^[0-9]+$/;
        var value = event.target.value;
        console.log('event hit value - > ', value );
        this.addYearsValue = value;
        if(!value.match(numbers)){
                this.addYearsError = true;
                event.target.classList.add('ltHasError');
                return false;	
        }
        else{
            this.addYearsError = false;
            event.target.classList.remove('ltHasError');
            return true;
        }
    }

    validateZip(event){
        var numbers = /^[0-9]+$/;
        var value = event.target.value;
        console.log('event hit value - > ', value );
        this.zipCodeValue = value;
        if(value.length < 5 || !value.match(numbers)){
                this.zipCodeError = true;
                event.target.classList.add('ltHasError');
                return false;	
        }
        else{
            this.zipCodeError = false;
            event.target.classList.remove('ltHasError');
            return true;
        }
    }

    checkZip(event){
        if(event.target.value.length < 5 ){
            this.zipCodeError = true;
            event.target.classList.add('ltHasError');
        }else {
            this.zipCodeError = false;
        }
    }

    formatRentAmount(event){
        console.log('eve hit', event.target.value );
        this.monthlyRentAmount = this.formatAmount(event.target.value);
        event.target.value = this.monthlyRentAmount;
        console.log('value - > ', this.monthlyRentAmount);
    }

    formatTaxAmount(event){
        console.log('evnt hit', event.target.value);
        this.yearlyTaxIncomeValue = this.formatAmount(event.target.value);
        event.target.value = this.yearlyTaxIncomeValue;
        console.log('value - > ', this.yearlyTaxIncomeValue);
    }

    formatSSN(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '').match(/(\d{0,3})(\d{0,3})(\d{0,3})/);
            event.target.value = !x[2] ? x[1] :  x[1] + '-' + x[2] + (x[3] ? '-' + x[3] : '');
            this.socialNumValue = event.target.value;
        }
    }

    validateSSN(event){
        if(event.target.value != null){
            var x = event.target.value.replace(/\D/g, '');
            console.log('x value '+ x);
            if(x.length != 9){
                this.socialInsuranceError = true;
            }else{
                this.socialInsuranceError = false;
            }
        }
        
    }

    formatAmount(ammVal) {
        var r = /[!$@#%^&*()_+a-zA-Z ]/g;
        ammVal = ammVal.replace(r,"");
        console.log('ammVal : '+ammVal);
        if (ammVal.length > 0) {
            var regex = new RegExp(',', 'g');
            ammVal = ammVal.replace(regex, '');
            console.log('ammVal : '+ammVal);
            var foramttedAmount = this.addCommas(ammVal.toString().substring(0, ammVal.length));
            /*if(!foramttedAmount.includes('$'))
                ammVal = '$' + foramttedAmount;
            else*/
            ammVal = '$' + foramttedAmount;
            console.log('ammVal : '+ammVal);
        }
        return ammVal;
    }

    monthlyAmountKeyCode(event){
        return (event.keyCode !=8 && event.keyCode ==0 || (event.keyCode >= 48 && event.keyCode <= 57))
    }

    consentClick(event){
        console.log('consent id', event.target.id);
        var contId = event.target.id;
        if( contId.includes('consent1') ){
            if(this.consent1){
                this.consent1 = false;
                event.target.checked = false;
            }else {
                this.consent1 = true;
            }
        }else if( contId.includes('consent2') ){
            if(this.consent2){
                this.consent2 = false;
                event.target.checked = false;
            }else {
                this.consent2 = true;
            }
        }else if( contId.includes('consent3') ){
            if(this.consent3){
                this.consent3 = false;
                event.target.checked = false;
            }else {
                this.consent3 = true;
            }
        }else if( contId.includes('consent4') ){
            if(this.consent4){
                this.consent4 = false;
                event.target.checked = false;
            }else {
                this.consent4 = true;
            }
        }else if( contId.includes('newsletter') ){
            if(this.newLetter){
                this.newLetter = false;
                event.target.checked = false;
            }else {
                this.newLetter = true;
            }
        }
    }

    checkSubmit(){
        console.log('check submit hit');
        console.log('totalNr : ',this.totalNr);
        var value = this.template.querySelector(".ebcaptchainput").value;
        var captchaInputEle = this.template.querySelector('ebcaptchainput');
        if(this.totalNr != value) { 
                this.template.querySelector(".captchaError").style.display = 'block';
                /*if(!captchaInputEle.classList.contains('captchaInputError')){
                    captchaInputEle.classList.add('captchaInputError');
                }*/
        }
        else if( this.consent1 && this.consent2 && this.consent3 && this.consent4 && this.agentCode !='' && this.agentCode != '' ){
            this.showSpinner = true;
            let leadObj = {
                amount : this.amount,//
                salutation : this.selectedSalutation,
                firstName : this.fistNameValue,
                lastName : this.lastNameValue,
                email : this.emailValue,
                phone : this.phoneValue,
                dateBirth : this.dateBirthValue,
                state : this.selectedStateValue,
                street : this.streetValue,
                city : this.cityValue,
                zipCode : this.zipCodeValue,
                residence : this.selectedResidenceValue,
                employment : this.selectedEmployStatus,
                creditScore : this.selectedCreditScore,
                monthlyRent : this.monthlyRentAmount,//
                taxIncome : this.yearlyTaxIncomeValue,
                agentCode : this.agentCodeVaue,//
                clientCode : this.clientCode,//
                sourceUrl : this.sourceUrl,
                socialNum : this.socialNumValue,
                payrollType : this.selectedPayrollType,
                payrollFeq : this.selectedPayrollFeq,
                employeeYears : this.selectedEmployeeYears,
                jobTitle : this.jobTitleValue,
                employerName : this.employerNameValue,
                highestEdu : this.selectedHighestEducation
            }
            console.log(leadObj);
            newLead({ obj : leadObj })
            .then((result) => {
                console.log('result from apex', result );
                //this.showSpinner = false;
                //this.page22 = false;
                if(result){
                    window.location = 'https://www.eazeconsulting.com/thank-you/?clnm='+this.fistNameValue;
                }/*else{
                    this.pageThankYouDeclined = true;
                }*/
                
            }).catch((error) =>{
                console.log('having error', error );
            });

        }
        
    }

    handleApplyNow(){
        console.log('handle click');
        this.frontPage = false;
        
        //const clientCodeList = ["U2OF0","6CFE3","KNRDV","K5E6K","VFXJR","NR3YR","4CBMR","D54KZ","JFPZJ","MFMOS","5STUS","CPE1M","KEKFP","HTXZ7","SBANL","5SCZY","TVLO5","H7KUN","GVGLZ","CJP0Y","SFR0A","83EDJ","IXP3W","MPJFE","INAFO","N2JRA","WCIP2","F5TUC","16NBF","2RLXY","1IPJL","DJPNV","RPWPX","GXN4Y","XTIM0","XRL0O","8KNBE","XHF5Q","FDVXF","FXVWH","RPWPX","RNHDC","CSLAE","8HRVP","LWNCA","FOSOQ","CKKXB","P2XAI","NTNYW","NFAH7","GEBW5","R4QI0","GDB28","LLLS1","PCZ3A","CP4Z7","8HP0H","2JUEA","RUI1H","XGRAF","EUUI0","O8DSJ","INUQT","W8KZZ","NZIDB","D1T68","LQLNM","NZIDB","JXXRG","O8DSJ","INUQT","CFDVZ","05X3W","55IYB","SRW9V"];
        if(this.removePreQual){ 
            this.page1 = true;
        }else{
            this.page1a = true;
        }
        //this.showLogo = true;
    }

    redirectPage(event){
        console.log('redirect click');
        this.currentPageId = event.target.id;
        console.log('current page Id', this.currentPageId );
        if(event != null && event != undefined && event.target != null && event.target != undefined ){

            console.log('id  - > ', event.target.id);
            var pageId = event.target.id;
            if( pageId.includes('page01') ){
                this.page1 = false;
                this.page2 = true;
                console.log(this.page1);
                console.log(this.page1a);
            }else if( pageId.includes('page02') ){
                if(!this.validManualAmountError){
                    this.page2 = false;
                    this.page3 = true;
                }
            }else if( pageId.includes('page02') ){
                if(!this.validManualAmountError){
                    this.page2 = false;
                    this.page3 = true;
                }
            }else if( pageId.includes('page03') ){
                if( this.fistNameValue != '' && this.lastNameValue != '' && this.selectedSalutation != '' ){
                    this.page3 = false;
                    this.page4 = true;
                    this.firstNameError = false;
                    this.lastNameError = false;
                    this.salutationError = false;
                }else if(this.fistNameValue == '' ){
                    this.firstNameError = true;
                }else if(this.lastNameValue == '' ){
                    this.lastNameError = true;
                }else if( this.selectedSalutation == ''){
                    this.salutationError = true;
                }
            }else if( pageId.includes('page04') ){
                if(this.validateEmail(this.emailValue) ){
                    this.page4 = false;
                    this.page5 = true;
                    this.emailError = false;
                    this.enterEmailError = false;
                }else {
                    this.enterEmailError = true;
                }
            }else if( pageId.includes('page05') ){
                if( this.phoneValue.length == 14){
                    this.page5 = false;
                    this.page6 = true;
                    this.phoneError = false;
                }else {
                    if(this.phoneValue == '' || this.phoneValue.length == 0 ){
                        this.enterPhoneError = true;
                        this.phoneError = false;
                    }else {
                        this.phoneError = true;
                        this.enterPhoneError = false;
                    }
                }
            }else if( pageId.includes('page6') ){
                if( this.isValidDate(this.dateBirthValue) ){
                    this.page6 = false;
                    this.page7 = true;
                    this.dateBirthError = false;
                }else{
                    this.dateBirthError = true;
                }
            }else if( pageId.includes('page7') ){
                if(!this.socialInsuranceError && this.socialNumValue.length > 9 ){
                    this.page7 = false;
                    this.page8 = true;
                }else {
                    this.socialInsuranceError = true;
                }
            }else if( pageId.includes('page8') ){
                if(this.dLicenceNum != '' && this.selectedDLStateValue.length != ''){
                    this.page8 = false;
                    this.page9 = true;
                    this.dlError = false;

                    
                }else {
                    this.dlError = true;
                }
            }else if( pageId.includes('page9') ){
                if( this.zipCodeValue.length == 5 ){
                    this.page9 = false;
                    this.page10 = true;
                }else {
                    if(this.zipCodeValue == '' ){
                        this.zipCodeEmpty = true;
                    }else{
                        this.zipCodeError = true;
                    }
                }
            }else if( pageId.includes('page10') ){
                if(this.selectedStateValue != '' && this.streetValue != '' && this.cityValue != '' ){
                    this.page10 = false;
                    this.page11 = true;
                    this.addressError = false;
                }else {
                    this.addressError = true;
                }

            }else if( pageId.includes('page11') ){

                if( this.addYearsValue != '' && this.addYearsError == false){
                    this.page11 = false;
                    this.page12 = true;
                } 
            }/*else if( pageId.includes('page12') ){

                if( pageId.includes('page12Own') ){
                    this.page12SelectedId = 'page12Own';
                    this.selectedResidenceValue = 'Own_Outright';
                }else if( pageId.includes('page12OwnWithMort') ){
                    this.page12SelectedId = 'page12OwnWithMort';
                    this.selectedResidenceValue = 'Own_with_Mortgage';
                }else if( pageId.includes('page12Rent') ){
                    this.page12SelectedId = 'page12Rent';
                    this.selectedResidenceValue = 'Rent';
                }else {
                    this.page12SelectedId = 'page12OTH';
                    this.selectedResidenceValue = 'Other';
                } 
                this.page12 = false;
                this.page13 = true;
            }*/else if( pageId.includes('page13') ){
                if(this.monthlyRentAmount != ''){
                    this.page13 = false;
                    this.page13a = true;
                    this.monthlyRentReq = false;
                }else {
                    this.monthlyRentReq = true;
                }
            }else if( pageId.includes('page14') ){
                if( pageId.includes('page14Ex') ){
                    this.page14SelectedId = 'page14Ex';
                    this.selectedCreditScore = 'excellent';
                }else if( pageId.includes('page14Go') ){
                    this.page14SelectedId = 'page14Go';
                    this.selectedCreditScore = 'Good';
                }else if( pageId.includes('page14Fa') ){
                    this.page14SelectedId = 'page14Fa';    
                    this.selectedCreditScore = 'fair';
                }else {
                    this.page14SelectedId = 'page14Po';
                    this.selectedCreditScore = 'poor';
                }
                this.page14 = false;
                this.page15 = true;
            }else if( pageId.includes('page15') ){

                if( pageId.includes('page15Ft')){
                    this.page15SelectedId = 'page15Ft';
                    this.selectedEmployStatus = 'Employed';
                }else if( pageId.includes('page15Pt')){
                    this.page15SelectedId = 'page15Pt';
                    this.selectedEmployStatus = 'Part Time';
                }else if( pageId.includes('page15Se')){
                    this.page15SelectedId = 'page15Se';
                    this.selectedEmployStatus = 'Self_Employed';
                    this.page15a = true;
                }else if( pageId.includes('page15Ue')){
                    this.page15SelectedId = 'page15Ue';
                    this.selectedEmployStatus = 'not_employed';
                }else if( pageId.includes('page15Re')){
                    this.page15SelectedId = 'page15Re';
                    this.selectedEmployStatus = 'retired';
                }else {
                    this.page15SelectedId = 'page15Ot';
                    this.selectedEmployStatus = 'Other';
                }

                this.page15 = false;
                if(this.selectedEmployStatus != 'Self_Employed'){
                    this.page16 = true;
                }
            }else if( pageId.includes('page16') ){
                if(this.yearlyTaxIncomeValue != ''){
                    this.page16 = false;
                    this.page17 = true;
                    this.yearlyTaxError = false;
                }else {
                    this.yearlyTaxError = true;
                }
            /*}else if( pageId.includes('page16') ){
                if(this.monthlyExpensValue != ''){
                    this.page16 = false;
                    this.page17 = true;
                    this.monthlyExpensError = false;

                    
                }else { 
                    this.monthlyExpensError = true;
                }*/
            }else if(pageId.includes('page17')){
                if( !this.employerNameError && this.employerNameValue.length > 0){
                    this.page17 = false;
                    this.page18 = true;
                }else{
                    this.employerNameError = true;
                }
            }else if( pageId.includes('page18') ){
                if( !this.jobTitleError && this.jobTitleValue.length > 0){
                    this.page18 = false;
                    this.page19 = true;
                }else{
                    this.jobTitleError = true;
                }
            }else if( pageId.includes('page19') ){
                if( pageId.includes('page19Less6') ){
                    this.page19SelectedId = 'page19Less6';
                    this.selectedEmployeeYears = 'Less than 6 months';
                }else if( pageId.includes('page19Month12') ){
                    this.page19SelectedId = 'page19Month12';
                    this.selectedEmployeeYears = '6-12 Months';
                }else if( pageId.includes('page19Year2') ){
                    this.page19SelectedId = 'page19Year2';
                    this.selectedEmployeeYears = '1-2 Years';
                }else if( pageId.includes('page19Year5') ){
                    this.page19SelectedId = 'page19Year5';
                    this.selectedEmployeeYears = '3-5 Years';
                }else {
                    this.page19SelectedId = 'page19YearPlus5';
                    this.selectedEmployeeYears = '5 + Years';
                } 
                this.page19 = false;
                this.page20 = true;
            }else if( pageId.includes('page20') ){
                if( pageId.includes('page20Weekly') ){
                    this.page20SelectedId = 'page20Weekly';
                    this.selectedPayrollFeq = 'Weekly';
                }else if( pageId.includes('page20BiWeekly') ){
                    this.page20SelectedId = 'page20BiWeekly';
                    this.selectedPayrollFeq = 'BiWeekly';
                }else if( pageId.includes('page20TwiceMonthly') ){
                    this.page20SelectedId = 'page20TwiceMonthly';
                    this.selectedPayrollFeq = 'Twice_Monthly';
                }else if( pageId.includes('page20Monthly') ){
                    this.page20SelectedId = 'page20Monthly';
                    this.selectedPayrollFeq = 'Monthly';
                }else {
                    this.page20SelectedId = 'page20Other';
                    this.selectedPayrollFeq = 'Other';
                } 
                this.page20 = false;
                this.page21 = true;
            }else if( pageId.includes('page21') ){
                if( pageId.includes('page21DirectlyDesposit') ){
                    this.page21SelectedId = 'page21DirectlyDesposit';
                    this.selectedPayrollType = 'direct_deposit';
                }else if( pageId.includes('page21PaperCheck') ){
                    this.page21SelectedId = 'page21PaperCheck';
                    this.selectedPayrollType = 'check';
                }else {
                    this.page21SelectedId = 'page21Cash';
                    this.selectedPayrollType = 'cash';
                } 
                this.page21 = false;
                this.page22= true;
                setTimeout(() => {
                    this.mathCaptcha();
                }, 2000);
            }
        }
    }

    redirectPageBack(event){
        console.log('back hit', event.target.id);
        this.currentPageId = event.target.id;
        var pageId = event.target.id;
        if( pageId.includes('page02') ){
            this.page1 = true;
            this.page2 = false;
        }else if( pageId.includes('page03') ){
            this.page3 = false;
            this.page2 = true;
        }else if( pageId.includes('page04') ){
            this.page4 = false;
            this.page3 = true;
        }else if( pageId.includes('page05') ){
            this.page5 = false;
            this.page4 = true;
        }else if( pageId.includes('page6') ){
            this.page6 = false;
            this.page5 = true;
        }else if( pageId.includes('page7') ){
            this.page7 = false;
            this.page6 = true;
        }else if( pageId.includes('page8') ){
            this.page8 = false;
            this.page7 = true;
        }else if( pageId.includes('page9') ){
            this.page9 = false;
            this.page8 = true;
        }else if( pageId.includes('page10') ){
            this.page10 = false;
            this.page9 = true;
        }else if( pageId.includes('page11') ){
            this.page11 = false;
            this.page10 = true;
        }else if( pageId.includes('page12') ){
            this.page12 = false;
            this.page11 = true;
        }else if( pageId.includes('page13') ){
            this.page13 = false;
            this.page12 = true;
        }else if( pageId.includes('page14') ){
            this.page14 = false;
            this.page13a = true;
        }else if( pageId.includes('page15') ){
            this.page15 = false;
            this.page14 = true;
        }else if( pageId.includes('page16') ){
            this.page16 = false;
            this.page15 = true;
        }else if( pageId.includes('page17') ){
            this.page17 = false;
            this.page16 = true;
        }else if( pageId.includes('page18') ){
            this.page18 = false;
            this.page17 = true;
        }else if( pageId.includes('page19') ){
            this.page19 = false;
            this.page18 = true;
        }else if( pageId.includes('page20') ){
            this.page20 = false;
            this.page19 = true;
        }else if( pageId.includes('page21') ){
            this.page21 = false;
            this.page20 = true;
        }else if( pageId.includes('page22') ){
            this.page22 = false;
            this.page21 = true;
        }
    }

    

    selfemployednext(event){
        console.log("event called " + event.detail);
        this.selectedSelfEmployeeYears = event.detail.message;
        this.page15aSelectedId = event.detail.selectedId;
        this.page15a = false;
        this.page16 = true;
    }

    selfemployedback(event){
        console.log("event called");
        this.currentPageId = event.detail.message;
        this.page15a = false;
        this.page15 = true;
    }

    higestEdunext(event){
        console.log("event called " + event.detail);
        this.selectedHighestEducation = event.detail.message;
        this.page13aSelectedId = event.detail.selectedId;
        this.page13a = false;
        this.page14 = true;
    }

    higestEduback(event){
        console.log("event called");
        this.currentPageId = event.detail.message;
        this.page13a = false;
        this.page13 = true;
    }

    residenceNext(event){
        console.log("event called " + event.detail);
        this.selectedResidenceValue = event.detail.message;
        this.page12SelectedId = event.detail.selectedId;
        this.page12 = false;
        this.page13 = true;
    }

    residenceBack(event){
        console.log("event called");
        this.currentPageId = event.detail.message;
        this.page12 = false;
        this.page11 = true;
    }

    manualAmountChange(event){
        var amount = event.target.value;
        this.amount = amount;
        console.log('amount', amount);
        if(amount >= parseInt(this.amountMin) && parseInt(this.amountMax) >= amount){
            this.amount = event.target.value;
            this.validManualAmountError = false;
            var currencyAmount = this.addCommas(event.target.value.toString());
            this.amountOutput = '$' + currencyAmount;
        }else{
            this.validManualAmountError = true;
        }
    }

    nextPage(event){
        //console.log(JSON.stringify(event.detail));
        this.page1a =  event.detail.page1a;
        this.page1 =  event.detail.page1;
        this.fistNameValue = event.detail.firstName;
        this.lastNameValue = event.detail.lastName;
        this.phoneValue = event.detail.phone;
        this.emailValue = event.detail.email;
    }

}