@isTest 
public without sharing class  Omni_TaskChangeOwnerTest {

    @isTest
    private static void changeOwnerTest(){ 

        Task testTask = new Task(); 
        insert testTask;
        Omni_AuraResponse auraResponse = Omni_TaskChangeOwner.changeOwner(testTask.Id);
        System.assertEquals(true, auraResponse.success, 'Change task owner should be sucessfull');

        auraResponse = Omni_TaskChangeOwner.changeOwner('abc');
        System.assertEquals(false, auraResponse.success, 'Change task owner should fail');
    }

}