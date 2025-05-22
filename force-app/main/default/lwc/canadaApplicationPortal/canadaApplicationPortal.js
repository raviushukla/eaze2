import { LightningElement,track,api,wire } from 'lwc';

import newCanadaLead from '@salesforce/apex/createNewCanadaLead.newCanadaLead';
import fetchAccount from '@salesforce/apex/createNewCanadaLead.fetchAccount';
import conversionRate from '@salesforce/apex/createNewCanadaLead.conversionRate';

//import easeLogo from '@salesforce/resourceUrl/canadaAppEaseLogo';
import candaAppEasy1 from '@salesforce/resourceUrl/candaAppEasy1';
import candaAppEasy2 from '@salesforce/resourceUrl/candaAppEasy2';
import candaAppEasy3 from '@salesforce/resourceUrl/candaAppEasy3';

import standardCss from '@salesforce/resourceUrl/StandardCss';
import standardLayoutCss from '@salesforce/resourceUrl/StandardLayoutCss';
import phoenixCss from '@salesforce/resourceUrl/PhoenixCss';
import ajaxFile from '@salesforce/resourceUrl/ajaxFile';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';


export default class CanadaApplicationPortal extends LightningElement{

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
    //showLogo = false;
    accCancel = false;
    logoImage = '';
    easyImage1 = candaAppEasy1;
    easyImage2 = candaAppEasy2;
    easyImage3 = candaAppEasy3;
    showIcon1 = true;answer1Div = false;
    showIcon2 = true;answer2Div = false;
    showIcon3 = true;answer3Div = false;
    showIcon4 = true;answer4Div = false;
    showIcon5 = true;answer5Div = false;
    showIcon6 = true;answer6Div = false;
    showIcon7 = true;answer7Div = false;
    showIcon8 = true;answer8Div = false;
    showIcon9 = true;answer9Div = false;
    showIcon10 = true;answer10Div = false;
    showIcon11 = true;answer11Div = false;
    showIcon12 = true;answer12Div = false;
    showIcon13 = true;answer13Div = false;
    showIcon14 = true;answer14Div = false;
    showIcon15 = true;answer15Div = false;

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

    sourceUrl = ''
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
        {
            "value":"AB" , "name":"Alberta", "selected":false
        },
        {
            "value":"BC" , "name":"British Columbia", "selected":false
        },
        {
            "value":"MB" , "name":"Manitoba", "selected":false
        },
        {
            "value":"NB" , "name":"New Brunswick", "selected":false
        },
        {
            "value":"NL" , "name":"Newfoundland and Labrador", "selected":false
        },
        {
            "value":"NT" , "name":"Northwest Territories", "selected":false
        },
        {
            "value":"NS" , "name":"Nova Scotia", "selected":false
        },
        {
            "value":"NU" , "name":"Nunavut", "selected":false
        },
        {
            "value":"ON" , "name":"Ontario", "selected":false
        },
        {
            "value":"PE" , "name":"Prince Edward Island", "selected":false
        },
        {
            "value":"SK" , "name":"Saskatchewan", "selected":false
        },
        {
            "value":"YT" , "name":"Yukon", "selected":false
        }
    ]

    @api
    get showLogo() {
        return true;
    }


    renderedCallback() {
        console.log('render hit');

        if( ( this.currentPageId.includes('page14back') || this.currentPageId.includes('page12') ) && this.page13SelectedId != '' ){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.page13SelectedId) ){
                    element.classList.add('selected');
                    console.log('class is add', element.classList )
                }
            });
        }

        if( (this.currentPageId.includes('page15back') || this.currentPageId.includes('page11') ) && this.page14SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                console.log('element id', element.id);
                if( element.id.includes(this.page14SelectedId) ){
                    element.classList.add('selected');
                    console.log('class is add', element.classList )
                }
            });
        }

        if(( this.currentPageId.includes('page12back') || this.currentPageId.includes('page10') ) && this.page11SelectedId != ''){
            this.template.querySelectorAll('label').forEach(element =>{
                    console.log('element id', element.id);
                    if( element.id.includes(this.page11SelectedId) ){
                        element.classList.add('selected');
                        console.log('class is add', element.classList )
                    } 
            })
        }

        if( this.currentPageId.includes('page20') ){
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
                    }else if( element.id.includes('newsletter') && this.newLetter == true ){
                        element.checked = true;
                        console.log('element id', element.id);
                    }else if( element.id.includes( 'p_b&c_p') && this.pastBankurpty == true ){
                        element.checked = true;
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
                /*loadStyle(this, bootstrapMin ),
                loadScript  (this, bootstrapCDN ),
                loadScript(this, popperMin)*/
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
        
        fetchAccount({clientId : this.clientCode})
        .then(result =>{
            console.log('result', result);
            this.logoImage = result.Logo_URL__c;
        }).catch(error =>{
            console.log(error);
        });

        conversionRate({})
        .then(result =>{
            console.log('Conversion rate result', result);
            this.usdConversionRate = result;
            this.amountOutputUSD = '$' + this.addCommas(((5000/this.usdConversionRate).toFixed(2)).toString());
        }).catch(error =>{
            console.log(error);
        });
        this.setAmmountForClient();

        
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
        this.amountOutputUSD = '$' + this.addCommas(((event.target.value/this.usdConversionRate).toFixed(2)).toString());
        this.amount = event.target.value;
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
        var clientList2 = ['GAYLG','OXAXH','QZEHR']; // amount:$4,000
        var clientList3 = ['NA4Y0']; // amount:$5,500
        var clientList4 = ['VCIL6']; // amount:$4,500
        var clientList5 = ['THN7O']; // min-amount:$4,500 and max-amount:$34,049
        var clientList6 = ['JORI6']; // min-amount:$5,000 and max-amount:$30,000
        var clientList7 = ['Z1OPL']; // min-amount:$5,000 and max-amount:$37,000
        var blockClients = ['RVBO5','TIE38'];
        
        if(clientList.includes(this.clientCode)){
            this.amountOutput = '$3,500';
            this.amountMin = '3500';
            this.amount = '3500';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$3.5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($3,500 min to $50,000 max)';
        }
        else if(clientList2.includes(this.clientCode)){
            this.amountOutput = '$4,000';
            this.amountMin = '4000';
            this.amount = '4000';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$4K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($4,000 min to $50,000 max)';
        }
        else if(clientList3.includes(this.clientCode)){
            this.amountOutput = '$5,500';
            this.amountMin = '5500';
            this.amount = '5500';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$5.5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($5,500 min to $50,000 max)';
        }
        else if(clientList4.includes(this.clientCode)){
            this.amountOutput = '$4,500';
            this.amountMin = '4500';
            this.amount = '4500';
            this.amountMax = '50000'
            this.lowerRangeAmount = '$4.5K';
            this.upperRangeAmount = '$50K';
            this.amountRangeInfo = '($4,500 min to $50,000 max)';
        }
        else if(clientList5.includes(this.clientCode)){
            this.amountOutput = '$5,000';
            this.amountMin = '5000';// min
            this.amount = '5000';
            this.amountMax = '34049';// max
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$34K';
            this.amountRangeInfo = '($5,000 min to $34,000 max)';
        }
        else if(clientList6.includes(this.clientCode)){
            this.amountOutput = '$5,000';
            this.amountMin = '5000';//min
            this.amount = '5000';
            this.amountMax = '30000';//max
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$30K';
            this.amountRangeInfo = '($5,000 min to $30,000 max)';
        }
        else if(clientList7.includes(this.clientCode)){
            this.amountOutput = '$5,000';
            this.amountMin = '5000';//min
            this.amount = '5000';
            this.amountMax = '37000';//max
            this.lowerRangeAmount = '$5K';
            this.upperRangeAmount = '$37K';
            this.amountRangeInfo = '($5,000 min to $37,000 max)';
        }
        else{
            this.amountOutput = '$5,000';
            this.amountOutputUSD = '$' + this.addCommas(((5000/this.usdConversionRate).toFixed(2)).toString());
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

    validateZip(event){
        var numbers = /^[A-Z0-9_ ]*$/;
        var value = event.target.value.toUpperCase().replace(/ /g,'');
        var first3 = value.substr(0,3);
        var last3 = value.substr(3,5);
        this.zipCodeEmpty = false;
        console.log('event hitnad value - > ', value );
        if(value.length > 7 || !value.match(numbers)){
                this.zipCodeError = true;
                event.target.classList.add('ltHasError');
                return false;	
        }
        else{
            this.zipCodeError = false;
            if(value.length > 3){
                this.zipCodeValue = first3 + ' ' + last3;
            }else{
                this.zipCodeValue = first3;
            }
            event.target.classList.remove('ltHasError');
            return true;
        }
    }

    checkZip(event){
        if(event.target.value.length < 6 ){
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

    formatExpenseAmount(event){
        console.log('event hit', event.target.value);
        this.monthlyExpensValue = this.formatAmount(event.target.value);
        event.target.value = this.monthlyExpensValue;
        console.log('value - > ', this.monthlyExpensValue);
        
    }
    formatSocialInsuranceNum(event){
        console.log('event hit', event.target.value);
        this.socialNumValue = this.formatSocialNum(event.target.value);
        event.target.value = this.socialNumValue;
        console.log('value - > ', this.socialNumValue);
        
    }

    formatSocialNum(ammVal) {
        var r = /[!$@#%^&*()_+a-zA-Z ]/g;
        ammVal = ammVal.replace(r,"");
        if(ammVal.length == 9){
            this.socialInsuranceError = false;
        }
        return ammVal;
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
        }else {
            if(this.pastBankurpty){
                this.pastBankurpty = false;
                event.target.checked = false;
            }else {
                this.pastBankurpty = true;
            }
        }
    }

    checkSubmit(){
        console.log('check submit hit');
        if( this.consent1 && this.consent2 && this.consent3  ){
            this.showSpinner = true;
            let leadObj = {
                amount : this.amount,
                salutation : this.selectedSalutation,
                firstName : this.fistNameValue,
                lastName : this.lastNameValue,
                email : this.emailValue,
                phone : this.phoneValue,
                dateBirth : this.dateBirthValue,
                citizenship : this.selectedCitizenshipValue,
                state : this.selectedStateValue,
                street : this.streetValue,
                city : this.cityValue,
                zipCode : this.zipCodeValue.replace(/ /g,''),
                residence : this.selectedResidenceValue,
                employment : this.selectedEmployStatus,
                creditScore : this.selectedCreditScore,
                monthlyRent : this.monthlyRentAmount,
                taxIncome : this.yearlyTaxIncomeValue,
                expence : this.monthlyExpensValue,
                newLetter : this.newLetter ? true : false,
                agentCode : this.agentCodeVaue,
                clientCode : this.clientCode,
                sourceUrl : this.sourceUrl,
                socialNum : this.socialNumValue,
                sourceUrl : this.sourceUrl,
                creditProposal : this.selectedConsumerProposal,
                pastBankurpty : this.selectedbankrupt,
                pastBankurptyLastSeven : this.selectedbankruptLastSeven,
            }
            console.log(leadObj);
            newCanadaLead({ obj : leadObj })
            .then((result) => {
                console.log('result from apex', result );
                this.showSpinner = false;
                this.page20 = false;
                if(result){
                    this.pageThankYou = true;
                }else{
                    this.pageThankYouDeclined = true;
                }
                
            }).catch((error) =>{
                console.log('having error', error );
            });

        }
    }

    handleApplyNow(){
        console.log('handle click');
        this.frontPage = false;
        this.page1 = true;
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
                console.log(this.page2);
            }else if( pageId.includes('page02') ){
                this.page2 = false;
                this.page3 = true;
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
                if(this.selectedCitizenshipValue != '' && this.selectedCitizenshipValue != 'undefined' ){
                    this.page7 = false;
                    this.page8 = true;
                }else {
                    this.citizenShipError = true;
                }
            }else if( pageId.includes('page8') ){
                if(this.socialNumValue != '' && this.socialNumValue.length == 9){
                    this.page8 = false;
                    this.page9 = true;
                    this.socialInsuranceError = false;

                    
                }else {
                    this.socialInsuranceError = true;
                }
            }else if( pageId.includes('page9') ){
                if( this.zipCodeValue.length == 7 ){
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

                if( pageId.includes('page11Own') ){
                    this.page11SelectedId = 'page11Own';
                    this.selectedResidenceValue = 'Own';
                }else if( pageId.includes('page11Rent') ){
                    this.page11SelectedId = 'page11Rent';
                    this.selectedResidenceValue = 'Rent';
                }else {
                    this.page11SelectedId = 'page11OTH';
                    this.selectedResidenceValue = 'Other';
                } 
                this.page11 = false;
                this.page12 = true;
            }else if( pageId.includes('page12') ){
                if(this.monthlyRentAmount != ''){
                    this.page12 = false;
                    this.page13 = true;
                    this.monthlyRentReq = false;
                }else {
                    this.monthlyRentReq = true;
                }
            }else if( pageId.includes('page13') ){
                if( pageId.includes('page13Ex') ){
                    this.page13SelectedId = 'page13Ex';
                    this.selectedCreditScore = 'excellent';
                }else if( pageId.includes('page13Go') ){
                    this.page13SelectedId = 'page13Go';
                    this.selectedCreditScore = 'Good';
                }else if( pageId.includes('page13Fa') ){
                    this.page13SelectedId = 'page13Fa';    
                    this.selectedCreditScore = 'fair';
                }else {
                    this.page13SelectedId = 'page13Po';
                    this.selectedCreditScore = 'poor';
                }
                this.page13 = false;
                this.page14 = true;
            }else if( pageId.includes('page14') ){

                if( pageId.includes('page14Ft')){
                    this.page14SelectedId = 'page14Ft';
                    this.selectedEmployStatus = 'Employed';
                }else if( pageId.includes('page14Pt')){
                    this.page14SelectedId = 'page14Pt';
                    this.selectedEmployStatus = 'Part Time';
                }else if( pageId.includes('page14Se')){
                    this.page14SelectedId = 'page14Se';
                    this.selectedEmployStatus = 'Self_Employed';
                }else if( pageId.includes('page14Ue')){
                    this.page14SelectedId = 'page14Ue';
                    this.selectedEmployStatus = 'not_employed';
                }else if( pageId.includes('page14Da')){
                    this.page14SelectedId = 'page14Da';
                    this.selectedEmployStatus = 'Disability';
                }else if( pageId.includes('page14Re')){
                    this.page14SelectedId = 'page14Re';
                    this.selectedEmployStatus = 'retired';
                }else if( pageId.includes('page14Sa')){
                    this.page14SelectedId = 'page14Sa';
                    this.selectedEmployStatus = 'Social Assistance';
                }else {
                    this.page14SelectedId = 'page14Ot';
                    this.selectedEmployStatus = 'Other';
                }

                this.page14 = false;
                this.page15 = true;
            }else if( pageId.includes('page15') ){
                if(this.yearlyTaxIncomeValue != ''){
                    this.page15 = false;
                    this.page16 = true;
                    this.yearlyTaxError = false;
                }else {
                    this.yearlyTaxError = true;
                }
            }else if( pageId.includes('page16') ){
                if(this.monthlyExpensValue != ''){
                    this.page16 = false;
                    this.page17 = true;
                    this.monthlyExpensError = false;

                    
                }else {
                    this.monthlyExpensError = true;
                }
            }else if(pageId.includes('page17')){
                if( pageId.includes('page17BankYes')){
                    this.page17SelectedId = 'page17BankYes';
                    this.selectedbankrupt = '1';
                    this.page18 = true;
                }else if( pageId.includes('page17BankNo')){
                    this.page17SelectedId = 'page17BankNo';
                    this.selectedbankrupt = '0';
                    this.page20 = true;
                    this.selectedConsumerProposal = '0';
                    this.selectedbankruptLastSeven = '0';
                }
                this.page17 = false;
            }else if( pageId.includes('page18') ){
                if(this.selectedbankruptLastSeven != ''){
                    this.page18 = false;
                    this.page19 = true;
                    this.bankruptError = false;
                    
                }else {
                    this.bankruptError = true;
                    
                }
            }else if( pageId.includes('page19') ){
                if(this.selectedConsumerProposal != '' ){
                    this.page19 = false;
                    this.page20 = true;
                    this.creditProposalError = false;

                    
                }else {
                    this.creditProposalError = true;
                    
                }
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
            this.page13 = true;
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
            if(this.selectedbankrupt == '0'){
                this.page20 = false;
                this.page17 = true;
            }else{
                this.page20 = false;
                this.page19 = true;
            }
        }
    }

    btnClick(event){
        var qtnId = event.target.id;
        console.log('qId',qtnId );
        if( qtnId.includes("question01") ){
            if(this.answer1Div == false){
                this.showIcon1 = false;
                this.answer1Div = true;
            }else {
                this.showIcon1 = true;
                this.answer1Div = false;
            }
        }else if( qtnId.includes("question2") ){
            if(this.answer2Div == false){
                this.showIcon2 = false;
                this.answer2Div = true;
            }else {
                this.showIcon2 = true;
                this.answer2Div = false;
            }
        }else if( qtnId.includes("question3") ){
            if(this.answer3Div == false){
                this.showIcon3 = false;
                this.answer3Div = true;
            }else {
                this.showIcon3 = true;
                this.answer3Div = false;
            }
        }else if( qtnId.includes("question4") ){
            if(this.answer4Div == false){
                this.showIcon4 = false;
                this.answer4Div = true;
            }else {
                this.showIcon4 = true;
                this.answer4Div = false;
            }
        }else if( qtnId.includes("question5") ){
            if(this.answer5Div == false){
                this.showIcon5 = false;
                this.answer5Div = true;
            }else {
                this.showIcon5 = true;
                this.answer5Div = false;
            }
        }else if( qtnId.includes("question6") ){
            if(this.answer6Div == false){
                this.showIcon6 = false;
                this.answer6Div = true;
            }else {
                this.showIcon6 = true;
                this.answer6Div = false;
            }
        }else if( qtnId.includes("question7") ){
            if(this.answer7Div == false){
                this.showIcon7 = false;
                this.answer7Div = true;
            }else {
                this.showIcon7 = true;
                this.answer7Div = false;
            }
        }else if( qtnId.includes("question8") ){
            if(this.answer8Div == false){
                this.showIcon8 = false;
                this.answer8Div = true;
            }else {
                this.showIcon8 = true;
                this.answer8Div = false;
            }
        }else if( qtnId.includes("question9") ){
            if(this.answer9Div == false){
                this.showIcon9 = false;
                this.answer9Div = true;
            }else {
                this.showIcon9 = true;
                this.answer9Div = false;
            }
        }else if( qtnId.includes("question10") ){
            if(this.answer10Div == false){
                this.showIcon10 = false;
                this.answer10Div = true;
            }else {
                this.showIcon10 = true;
                this.answer10Div = false;
            }
        }else if( qtnId.includes("question11") ){
            if(this.answer11Div == false){
                this.showIcon11 = false;
                this.answer11Div = true;
            }else {
                this.showIcon11 = true;
                this.answer11Div = false;
            }
        }else if( qtnId.includes("question12") ){
            if(this.answer12Div == false){
                this.showIcon12 = false;
                this.answer12Div = true;
            }else {
                this.showIcon12 = true;
                this.answer12Div = false;
            }
        }else if( qtnId.includes("question13") ){
            if(this.answer13Div == false){
                this.showIcon13 = false;
                this.answer13Div = true;
            }else {
                this.showIcon13 = true;
                this.answer13Div = false;
            }
        }else if( qtnId.includes("question14") ){
            if(this.answer14Div == false){
                this.showIcon14 = false;
                this.answer14Div = true;
            }else {
                this.showIcon14 = true;
                this.answer14Div = false;
            }
        }else if( qtnId.includes("question15") ){
            if(this.answer15Div == false){
                this.showIcon15 = false;
                this.answer15Div = true;
            }else {
                this.showIcon15 = true;
                this.answer15Div = false;
            }
        }
    }
}