/**
* @description Populate Case role record values for auto notification
* @author      Kejia Hu
* @date        16/10/2019                     
*/
public with sharing class CaseTriggerHandler implements TriggerHandlerBase {

    public String getObjectAPIName() {
        return 'Case';
    }

    public void handleBeforeInsert(List<SObject> listNew) {
        //Only process Case records having role as type
        // List<Case> roles = CaseTriggerHandlerHelper.retrieveRolesFromCases(listNew);
        // if(!roles.isEmpty()) {
        //     //Get all Owner Ids from Roles
        //     Set<Id> userIds = CaseTriggerHandlerHelper.getUserIdSetFromRoles(listNew); 
        //     //Query user detail information
        //     Map<Id, User> userById = Omni_UserSelector.getUserDetailsById(userIds);
        //     //Get all case Ids include roles/claim/exposure
        //     Set<Id> roleIds = CaseTriggerHandlerHelper.getRefIdSetFromRoles(roles);
        //     //Get Party Account 
        //     Set<Id> partyAccountIds = CaseTriggerHandlerHelper.getPartyAccIdSetFromRoles(roles);
        //     Map<Id, Account> accountById = Omni_AccountSelector.getPartyAccountDetailsById(partyAccountIds);
        //     //Get Party Contact
        //     Set<Id> partyContactIds = CaseTriggerHandlerHelper.getPartyContactIdSetFromRoles(roles);
        //     Map<Id, Contact> contactById = Omni_ContactSelector.getPartyContactDetailsById(partyContactIds);
        //     //Get all roles related Case Object data details
        //     Map<Id, Case> caseById = Omni_CaseSelector.getClaimExpoDetailsById(roleIds);
        //     for (case role : roles) {
        //         role = CaseTriggerHandlerHelper.populateRoleWithReferenceBeforeInsert(role, caseById.get(role.ClaimForRole__c), caseById.get(role.ExposureForRole__c),
        //                                              userById.get(role.OwnerId), accountById.get(role.PartyAccount__c), contactById.get(role.PartyContact__c));
        //     }
        // }
    }
    
    public void handleBeforeUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Only process Case records having role as type
        // List<Case> roles = CaseTriggerHandlerHelper.retrieveRolesFromCases(mapNew.values());
        // if(!roles.isEmpty()) {
        //     //Get all Owner Ids from Roles
        //     Set<Id> userIds = CaseTriggerHandlerHelper.getUserIdSetFromRoles(mapNew.values()); 
        //     //Query user detail information
        //     Map<Id, User> userById = Omni_UserSelector.getUserDetailsById(userIds);
        //     //Get all case Ids include roles/claim/exposure
        //     Set<Id> roleIds = CaseTriggerHandlerHelper.getRoleIdSetFromRoles(roles);
        //     //Get all roles related Case Object data details
        //     Map<Id, Case> caseById = Omni_CaseSelector.getCaseDetailsById(roleIds);
        //     for (case role : roles) {
        //         role = CaseTriggerHandlerHelper.populateRoleWithReference(role, caseById.get(role.Id), userById.get(role.OwnerId));
        //     }
        // }
    }
    
    public void handleBeforeDelete(Map<Id, SObject> mapOld) {
        //Placeholder for Before Delete logic
        return;
    }
    
    public void handleAfterInsert(Map<Id, SObject> mapNew) {
        //Placeholder for After Insert logic
        return;
    }
    
    public void handleAfterUpdate(Map<Id, SObject> mapNew, Map<Id, SObject> mapOld) {
        //Placeholder for After Update logic
        return;
    }
    
    public void handleAfterDelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Delete logic
        return;
    }
    
    public void handleAfterUndelete(Map<Id, SObject> mapOld) {
        //Placeholder for After Undelete logic
        return;
    }

}