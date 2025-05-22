@isTest
public class loanServicingEmailService_Test {
    
    testMethod static void method(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        
        email.subject = 'Test';
        email.fromname = 'Test Test';
        env.fromAddress = 'Test@email.com';
        email.plainTextBody = 'Test';
        
        Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
        attachment.body = blob.valueOf('businessStartDate,businessName,businessType,incorporationDate,street1,street2,city,state,zipCode,website,businessEmail,phoneNumber,stateIncorporated,numberOfLocations,programNameSet,programSubNameSet,firstName,lastName,mobile,email,percentageOwnerShip,ownershipStartDate,niche,currentMonthlyVolume,isCurrentPaymentPlanExists,amountOfHours,paymentPlanCompletionPercentage,depositRequired,programDuration,pricepoint,paymentExtension,paymentPlanChoice,offerPaymentPlans,currentMonthlyVolume'+'\n'+
                                      + 'ISODate,Eaze Consultancy,LIMITED_LIABILITY_COMPANY,ISODate,Newport Center Drive,Suite 1100,Newport Beach,CA,92660,https://www.eazeconsulting.com/,contact@eazeconsulting.com,2212222222,CA,1,Retail,Training/Coaching,John,Smith,2122222222,jsmith@eazeconsulting.com,100,ISODate,Consulting Servicer,"$11,000 - $24,000",Yes,20-29 hrs./mo.,50%,No,9 months,"$15,000 - $19,999",13 - 18 pay,Not having to deal with the headaches and hassles of payment plans,Right away,"$10,000 or Lesser"');
        attachment.fileName = 'textfile.txt';
        attachment.mimeTypeSubType = 'text/plain';
        email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
            
        loanServicingEmailService emailProcess = new loanServicingEmailService();
        emailProcess.handleInboundEmail(email, env);
    }
}