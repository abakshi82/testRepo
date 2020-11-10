public without sharing class Omni_Aura_SMSStartSessionController {

    @AuraEnabled
    public static Omni_AuraResponse verifyMessagingUser(String caseId) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        MessagingEndUser msgUsr;
        try{
            Case cas = Omni_CaseSelector.getCaseAccountInformationById(caseId)[0];
            String phoneNumber = preprocessPhoneNumber(cas.PartyAccount__r.Phone);
            if(phoneNumber == null){
                auraResponse.success = false;
                auraResponse.message = 'Phone number for related Person Account is invalid';
            }else{
                List<MessagingEndUser> meu = Omni_MessagingEndUserSelector.getMessagingEndUserByPhoneNumber(phoneNumber);
                if(meu.isEmpty()){
                    MessagingChannel msgChannel = Omni_MessagingChannelSelector.getMessagingChannelByName(Omni_SMSConstant.MESSAGING_CHANNEL_NAME);
                    msgUsr = new MessagingEndUser(
                        AccountId       = cas.PartyAccount__c,
                        MessageType     = Omni_SMSConstant.MESSAGING_USER_TYPE,
                        MessagingChannelId   = msgChannel.Id,
                        MessagingPlatformKey = phoneNumber,
                        Name                 = phoneNumber,
                        IsOptedOut           = false
                    );   
                    insert msgUsr;  
                }else{
                    msgUsr = meu[0];
                }
                auraResponse.data = msgUsr;
            }
        }catch (Exception e) {
            System.debug(e);
            ApplicationLogHandler.saveExceptionLog(Omni_SMSConstant.TWO_WAY_SMS_APPLICATION_NAME, e , null);
            auraResponse.success = false;
            auraResponse.message = 'Messaging is unavailable for this Role. Contact your admin for help';
        }
        return auraResponse;
    }

    public static String preprocessPhoneNumber(String accountPhoneNumber){
        if(accountPhoneNumber == null){
            return null;
        }
        if(accountPhoneNumber == ''){
            return null;
        }
        //replace all non-digits
        accountPhoneNumber = accountPhoneNumber.replaceAll('[^0-9]','');
        if(!accountPhoneNumber.startsWith('+1')){
            accountPhoneNumber='+1'+accountPhoneNumber;
        }
        
        if(accountPhoneNumber.length() == 12 && !accountPhoneNumber.startsWith('+1')){
            return null;   
        }
        
        return accountPhoneNumber;
    }
}