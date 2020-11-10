public class KJ_Test {

    public static void sendEmail(Id parentId){
        List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
        m.setTemplateId([SELECT Id FROM EmailTemplate where Name = 'EN AB Survey Test'].Id);
        m.setWhatId(parentId);
        m.setTargetObjectId('0034c000001xF7kAAE');
        messagesToSend.add(m);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messagesToSend, false);
        System.debug(results);
    }
    
    public static void sendEmail() {
        SurveyRole__c surveyRole= new SurveyRole__c(ClaimNumber__c = 'Claim number retrieved from Survey Role');
        insert surveyRole;
        Account acc = new Account(Name = 'SurveyTest');
        insert acc;
        Contact con = new Contact(FirstName = 'SurveyTest', LastName = 'SurveyTest', AccountId = acc.Id, Email = 'kejia.hu@intact.net');
        insert con;
        List<Messaging.SingleEmailMessage> messagesToSend = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage m = new Messaging.SingleEmailMessage();
        m.setTemplateId([SELECT Id FROM EmailTemplate where Name = 'EN AB Survey Test'].Id);
        m.setWhatId(surveyRole.Id);
        //m.setTargetObjectId('0034c000001xF7kAAE');
        m.setTargetObjectId(con.Id);
        messagesToSend.add(m);
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messagesToSend, false);
        System.debug(results);
        delete surveyRole;
        delete con;
        delete acc;
    }
}