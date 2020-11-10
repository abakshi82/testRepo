public without sharing class Omni_EmailMessageService {

    public static void updateOutboundEmails(List<EmailMessage> emailMessages){
        Map<Id, Profile> allowedProfiles = Omni_EmailMessageService.ALLOWED_PROFILES;
        for(EmailMessage emailMsg : emailMessages){ 
            if(!emailMsg.Incoming && 
                emailMsg.validatedFromAddress != Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('NotificationFromAddress') &&
                allowedProfiles.containsKey(UserInfo.getProfileId())){
                
                emailMsg.validatedFromAddress = Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('NotificationFromAddress');
            }
        }
    }
    
    public static final Map<Id, Profile> ALLOWED_PROFILES {
        get{
            if (null == ALLOWED_PROFILES) {
                List<String> AGENT_PROFILES = new List<String>{'Claims - Agent Full License', 'Claims - Agent Read Only User', 'Claims - Business Super User'};
                ALLOWED_PROFILES =  new Map<Id, Profile>([SELECT Id
                                                          FROM Profile
                                                          WHERE Name IN: AGENT_PROFILES]);
            }
            return ALLOWED_PROFILES;
        }
        set;
    }
}