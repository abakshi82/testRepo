/**
* @Description: Test class for Omni_Aura_SMSStartSessionController
* @Author:      Damian Kazior, PwC
* @Date:        20/01/2020
*/
@isTest
public with sharing class Omni_Aura_SMSStartSessionControllerTest {

    @TestSetup
    static void setupData(){ 
        //create few exposures with claims
        List<Case> cases = TestDataFactory.createOtherExposures(1); 
        List<Case> exposureRoles = TestDataFactory.createExposureRoles(cases);
    }  

    @isTest
    private static void verifyMessagingUserSuccess() {
        Case role = [SELECT Id FROM Case WHERE RecordTypeId =: Omni_ClaimEventConstant.RECORD_TYPE_ID_EXPO_ROLE][0];
        Omni_AuraResponse auraResponse = Omni_Aura_SMSStartSessionController.verifyMessagingUser(role.Id);
        System.assertEquals(true, auraResponse.success, 'There should be no error');
        System.assertNotEquals(null, auraResponse.data, 'Mesaging user should be returned'); 
    }

    @isTest
    private static void verifyMessagingUserFail() {
        Omni_AuraResponse auraResponse = Omni_Aura_SMSStartSessionController.verifyMessagingUser(null);
        System.assertEquals(false, auraResponse.success, 'Error should be returned');
    }

     @isTest
    private static void preprocessPhoneNumberSuccess() {
        Omni_Aura_SMSStartSessionController.preprocessPhoneNumber(null);
        Omni_Aura_SMSStartSessionController.preprocessPhoneNumber('');
    }

}