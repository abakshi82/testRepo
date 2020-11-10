/**
* @description VF page controller for Preview Edit Print Letter and save letter
* @author      Kejia Hu
* @date        27/06/2019                     
*/
public without sharing class Omni_PreviewEditPrintLetterController {
    
    public String tempId {get; set;}
    public String caseId {get; set;}
    public String letterBody {get;set;}
    public String letterTextBody {get;set;}
    public String letterSubject {get;set;}
    public Case role;
    
    public Omni_PreviewEditPrintLetterController() {
        tempId = apexpages.currentpage().getparameters().get('tempId');
        caseId = apexpages.currentpage().getparameters().get('caseId');
        role = [SELECT Id, PartyContact__c, RecordTypeId, ExposureForRole__r.ExposureType__c, Party_Province__c,
                        Party_Address_Line__c, Party_City__c, Party_First_Name__c, Party_Last_Name__c, Party_Postal_Code__c 
                FROM Case 
                WHERE Id = :caseId];
        letterBody = this.getBody();
    }
    
    /**
    * @description OM-32 generate Email template body
    * @author      Kejia Hu
    * @date        27/06/2019                     
    */
    public String getBody() {
        EmailTemplate emailTemp = [Select Id, Name, Subject, Body, HtmlValue from EmailTemplate where Id =:tempId];
        Messaging.SingleEmailMessage sem = Messaging.renderStoredEmailTemplate(emailTemp.Id, role.PartyContact__c, role.Id);
        String fullName = (String.isBlank(role.Party_First_Name__c)) 
                        ? role.Party_Last_Name__c
                        : role.Party_Last_Name__c + ' ' + role.Party_First_Name__c;
        String headerHTML = 'Destination: <br/>' + 
            				'&nbsp;&nbsp;&nbsp;&nbsp;' + fullName + ' <br/>' + 
            				'&nbsp;&nbsp;&nbsp;&nbsp;' + role.Party_Address_Line__c + ' <br/>' + 
            				'&nbsp;&nbsp;&nbsp;&nbsp;' + role.Party_City__c + ', ' + role.Party_Province__c + ', ' + role.Party_Postal_Code__c + ' <br/><br/>';
        String headerTxt =  'Destination:  \n' + 
            				fullName + '  \n' + 
            				role.Party_Address_Line__c + '  \n' +
            				role.Party_City__c +', ' + role.Party_Province__c + ', ' + role.Party_Postal_Code__c  + ' \n';
        letterTextBody = headerTxt + sem.getPlainTextBody();
        letterSubject = 'Print Letter: ' + emailTemp.Name;
        return headerHTML + sem.getHtmlBody();
    }
    
    /**
    * @description OM-32 Save letter to Email Message and redirect to PDF 
    * @author      Kejia Hu
    * @date        27/06/2019                     
    */
    public pageReference saveAndShowPDF() {
        EmailMessage email = new EmailMessage();
        email.Subject = this.letterSubject;
        email.HtmlBody = this.letterBody;
        email.TextBody = this.letterTextBody;
        email.ParentId = caseId;
        email.RelatedToId =  caseId;
        email.MessageType__c =  Omni_ClaimEventConstant.COMM_CHANNEL_PRINT;
        insert email;
        PageReference pageRef = new PageReference('/apex/OMNI_ViewPrintLetterAsPDF?emailId='+email.Id);
        pageRef.setRedirect(true);
        return pageRef;
    }

    /**
    * @description OM-32 return to case record
    * @author      Kejia Hu
    * @date        27/06/2019                     
    */
    public pageReference returnToCase() {
        PageReference pageRef = new PageReference('/'+caseId);
        pageRef.setRedirect(true);
        return pageRef;
    }
}