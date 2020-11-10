public without sharing class Omni_Aura_MessagingSessionCtrlNoShare {

    /*
    Agent can select a claim/exposure that he has access to. Sharing for a search box is implemented in 
    Omni_Aura_MessagingSessionController and is selecting appropiate claims and exposures. 
    Unfortunately there is a bug in Salesforce messaging that throws INSUFFICIENT_ACCESS_ON_CROSS_REFERENCE_ENTITY error
    when user tries to assign case to session that he has access to inside of a class that is defined as with sharing. 
    Therefore this one method is exposed in separate, without sharing class to workaround the bug. 
    */ 
    public static Omni_AuraResponse updateSession(String sessionId, String claimId) {
        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        try{
            MessagingSession msgSession = [select Id, CaseId FROM MessagingSession where id=:sessionId];
            msgSession.CaseId = claimId;
            update msgSession;
        }catch(Exception e){
            ApplicationLogHandler.saveExceptionLog('Omni_Aura_MessagingSessionController', e, null); 
            System.debug('error:'+e.getmessage());
            auraResponse.success = false;
        }
        return auraResponse;
    }
}