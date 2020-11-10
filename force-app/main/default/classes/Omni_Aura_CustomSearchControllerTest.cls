/**
* @Description: Test class for Omni_Aura_CustomSearchController
* @Author:      Damian Kazior, PwC
* @Date:        20/01/2020
*/
@isTest
public with sharing class Omni_Aura_CustomSearchControllerTest {

    @TestSetup
    static void setupData(){
        //create few exposures with claims
        TestDataFactory.createOtherExposures(TestDataFactory.TEST_SIZE_SMALL); 
    }  

    @isTest
    private static void fetchLookUpValuesSuccess() {
        Case testCase = [SELECT ClaimNumber__c FROM Case WHERE ClaimNumber__c != null Limit 1];
        Omni_AuraResponse auraResponse = Omni_Aura_CustomSearchController.fetchLookUpValues(testCase.ClaimNumber__c.substring(0,3));
        System.assertEquals(true, auraResponse.success, 'There should be no error');
        System.assertNotEquals(0, auraResponse.dataList.size(), 'There must be at least one result');
    }
}