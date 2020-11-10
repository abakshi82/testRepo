({
   /**
    * @Description: Navigate to setup page for email template 
    * @Author:      Damian Kazior, PwC
    * @Date:        02/07/2019
    */
   navigateToEmailSetup: function(templateId, isCreate) { 
    var pathName = window.location.pathname; 
    if(isCreate){
      window.open(window.location.protocol +"//" + window.location.hostname+
                  "/lightning/setup/CommunicationTemplatesEmail/page?address=%2Fp%2Femail%2Ftemplate%2FNewEmailTemplateStageManager%3Fsetupid%3DCommunicationTemplatesEmail", '_blank');
   }else{
      window.open(window.location.protocol +"//" + window.location.hostname+
                  "/lightning/setup/CommunicationTemplatesEmail/page?address=%2F" +
                  templateId+
                  "%3Fsetupid%3DCommunicationTemplatesEmail", '_blank');
    }
   
 
}    
})