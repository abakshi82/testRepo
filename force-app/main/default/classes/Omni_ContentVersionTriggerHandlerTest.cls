/**
* @description Test class for Omni_ContentVersionTriggerHandler
* @author      Damian Kazior
* @date        23/08/2019                     
*/
@isTest
private class Omni_ContentVersionTriggerHandlerTest {

    @isTest
    static void handleBeforeInsertPositive(){
        User knowledgeAuthorUser = TestDataFactory.createrUserWithProfile('KB - Author User');
        ContentVersion dummyFile = TestDataFactory.generateFile('xyz', 'test', false);
        boolean errorThrown = false;
        System.runAs(knowledgeAuthorUser){
            try{
                insert dummyFile;
            }catch(Exception e){
                errorThrown = true;
            }
        }
        System.assertEquals(false, errorThrown, 'Knowledge author should be allowed to upload files');
    }

    @isTest
    static void handleBeforeInsertNegative(){
        User readOnlyUser = TestDataFactory.createrUserWithProfile('Claims - Agent Read Only User');
        ContentVersion dummyFile = TestDataFactory.generateFile('xyz', 'test', false);
        boolean errorThrown = false;
        System.runAs(readOnlyUser){
            try{
                insert dummyFile;
            }catch(Exception e){
                errorThrown = true;
            }
        }
        System.assertEquals(true, errorThrown, 'Read only user should not be allowed to upload files');
    }

    @isTest
    static void coverageMethods(){
        ContentVersion dummyFile = TestDataFactory.generateFile('xyz', 'test', true);
        dummyFile.Title = 'newtitle';
        update dummyFile;
        Test.startTest();
        Omni_ContentVersionTriggerHandler handler = new Omni_ContentVersionTriggerHandler();
        handler.handleBeforeDelete(null);
        handler.handleAfterDelete(null);
        handler.handleAfterUndelete(null);
        Test.stopTest();
        System.assertEquals('ContentVersion', handler.getObjectAPIName(),'Object name should be ContentVersion');
    }
}