/**
* @Description: Test class Omni_CloseWorkMergeCaseButton lightning component Controller
* @Author:      Kejia Hu
* @Date:        23/01/2020
*/
@isTest
private class Omni_MergeCase_Test {

    @isTest
    static void testMerge() {
        Case otherExposure = TestDataFactory.createOtherExposures(1)[0];
        Case emailCase = new Case(Origin='Email', RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(
                                                                    'EmailCase').getRecordTypeId());
        insert emailCase;
        EmailMessage email = new EmailMessage(ParentId = emailCase.Id);
        insert email;
        String returnId = Omni_MergeCase_AuraController.mergeCaseToMaster(emailCase.Id, otherExposure.Id);
        System.assertEquals(otherExposure.Id, returnId, 'Controller method should return the master case id');
    }
}