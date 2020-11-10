/**
* @Description: Test class for Omni_Aura_MessagingSessionController
* @Author:      Damian Kazior, PwC
* @Date:        20/01/2020
*/
@isTest
public class Omni_Aura_MessagingSessionControllerTest {

    @TestSetup
    static void setupData(){ 
        //create few exposures with claims
        List<Case> cases = TestDataFactory.createOtherExposures(TestDataFactory.TEST_SIZE_SMALL); 
        List<Case> exposureRoles = TestDataFactory.createExposureRoles(cases);
        MessagingEndUser msgUser = TestDataFactory.createMessagingEndUser(true);
        MessagingSession msgSession = TestDataFactory.createMessagingSessionForEndUser(msgUser, false);
        msgSession.CaseId = cases[0].Id;
        insert msgSession;
    }  

    @isTest
    private static void fetchCaseForSessionSuccess() {
        MessagingSession msgSession = [SELECT Id FROM MessagingSession Limit 1][0];
        Omni_AuraResponse auraResponse = Omni_Aura_MessagingSessionController.fetchCaseForSession(msgSession.Id);
        System.assertEquals(true, auraResponse.success, 'There should be no error');
        System.assertEquals(1, auraResponse.dataList.size(), 'Session should be returned'); 
    }

    @isTest
    private static void fetchCasesForPhoneNumberSuccess() {
        MessagingSession msgSession = [SELECT Id FROM MessagingSession Limit 1][0];
        List<Account> partyAccounts = [SELECT Phone FROM Account];
        MessagingEndUser msgEndUser = [select MessagingPlatformKey FROM MessagingEndUser LIMIT 1][0];
        for(Account acc : partyAccounts){
            acc.Phone = msgEndUser.MessagingPlatformKey;
        } 
        update partyAccounts;
        Omni_AuraResponse auraResponse = Omni_Aura_MessagingSessionController.fetchCasesForPhoneNumber(msgSession.Id);
        System.assertEquals(true, auraResponse.success, 'There should be no error');
        System.assertNotEquals(null, auraResponse.dataList, 'List should be returned');
    }

    @isTest
    private static void updateSessionSuccess() {
        MessagingSession msgSession = [SELECT Id FROM MessagingSession Limit 1][0];
        Case testCase = [SELECT Id FROM Case Limit 1][0];
        Omni_AuraResponse auraResponse = Omni_Aura_MessagingSessionController.updateSession(msgSession.Id, testCase.Id);
        System.assertEquals(true, auraResponse.success, 'There should be no error');
    }    
    

}