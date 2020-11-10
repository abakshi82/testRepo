/**
* @description VF page controller for Preview Print Letter as PDF
* @author      Kejia Hu
* @date        27/06/2019                     
*/
public with sharing class Omni_ViewPrintLetterAsPDFController {
    
    public String emailId {get; set;}
    
    public Omni_ViewPrintLetterAsPDFController() {
        this.emailId = apexpages.currentpage().getparameters().get('emailId');
    }
    
    /**
    * @description OM-34 retrieve email html body
    * @author      Kejia Hu
    * @date        27/06/2019                     
    */
    public String getBody() {
        String toReturn;
        EmailMessage em = Omni_EmailMessageSelector.getEmailMessageFromId(this.emailId);
        if(null != em) {
            toReturn = em.HtmlBody;
        }
        return toReturn;
    }
}