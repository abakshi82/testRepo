/**
* @description Test class for Omni_ContentVersionTriggerHandler
* @author      Damian Kazior
* @date        23/08/2019                     
*/
@isTest
private class Omni_UserTriggerHandlerTest { 

    @isTest
    static void validateUserUpdatesPermissionsPositive(){
        User integrationUser = TestDataFactory.createrUserWithProfile('Intg - Provisioning');
        boolean errorThrown = false;
        System.runAs(integrationUser){
            try{
                integrationUser.lastName = 'DummyName';
                update integrationUser;
            }catch(Exception e){
                errorThrown = true;
            }
        }
        System.assertEquals(false, errorThrown, 'Integration user should be allowed to update users');
    }

    @isTest
    static void validateUserUpdatesPermissionsNegative(){
        User readOnlyUser = TestDataFactory.createrUserWithProfile('Claims - Agent Read Only User');
        boolean errorThrown = false;
        System.runAs(readOnlyUser){
            try{
                readOnlyUser.lastName = 'DummyName';
                update readOnlyUser;
            }catch(Exception e){
                errorThrown = true;
            }
        }
        System.assertEquals(true, errorThrown, 'Read only user should not be allowed to update user record');
    }

    @isTest
    static void coverageMethods(){
        Test.startTest();
        Omni_UserTriggerHandler handler = new Omni_UserTriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('User', handler.getObjectAPIName(),'Object name should be User');
    }
}