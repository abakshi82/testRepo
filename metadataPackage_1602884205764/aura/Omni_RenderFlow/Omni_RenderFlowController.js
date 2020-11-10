({
    /**
     * @description Initiates Flow contained in the lightning component
     * @author      Luis Merinero
     * @date        20/12/2019                     
     */
    doInit: function(component, event, helper) {
        var flow = component.find("flowRenderer");
        var recordId = component.get("v.pageReference").state.c__claimId;
        var inputVariables = [{
            name: 'recordId',
            type: 'String',
            value: recordId
        }];
        if ($A.util.isEmpty(inputVariables)) {
            flow.startFlow("Ad_hoc_Email_Communitcation");
        } else {
            flow.startFlow("Ad_hoc_Email_Communitcation", inputVariables);
        }

    },

    populateSelectedRole: function(component, event, helper) {
        console.log('accepted:' + event.getParam("roleCase").Id);
        var roleCase = event.getParam("roleCase");
        //populate list of selected emails (left pane)
        var flowStageOfSelection = event.getParam("stage");
        var language = event.getParam("sLanguage");
        var exposure = event.getParam("sExposure");
        var claimNumber = event.getParam("sClaimNumber");
        if (flowStageOfSelection == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
            var allRolesSelected = component.get("v.allRolesSelected");
            allRolesSelected = helper.populateRecipientRole(component, allRolesSelected, roleCase)
            var allRoleIdsSelected = helper.extractIdFromRoles(allRolesSelected)
            var allEmailsSelected = helper.extractEmailsFromRoles(allRolesSelected);
            component.set("v.allRolesSelected", allRolesSelected);
            component.set("v.allRoleIdsSelected", allRoleIdsSelected);
            component.set("v.allEmailsSelected", allEmailsSelected);
            helper.validateRecipientEmails(component);
        } else {
            var allCCRolesSelected = component.get("v.allCCRolesSelected");
            allRolesSelected = helper.populateRecipientRoleForCC(component, allCCRolesSelected, roleCase)
            component.set("v.allCCRolesSelected", allCCRolesSelected);
            var allCCEmailsSelected = helper.extractEmailsFromRoles(allRolesSelected);
            component.set("v.allCCEmailsSelected", allCCEmailsSelected);
        }
        helper.passChosenRolesToFlow(component, flowStageOfSelection, language, exposure, claimNumber);
    },

    populateSelectedExposure: function(component, event) {
        var exposureCase = event.getParam("exposureCase");
        component.set("v.exposureCaseSelected", exposureCase);
    },

    populateManualEmails: function(component, event, helper) {
        var flowStageOfSelection = event.getParam("flowStage");
        if (flowStageOfSelection == $A.get("$Label.c.Omni_Adhoc_Recipient")) {
            var emails = event.getParam("RoleEmails");
            component.set("v.manualRoleEmails", emails);
            helper.validateRecipientEmails(component);
            helper.passChosenManualEmailsToFlow(flowStageOfSelection, emails);
        } else {
            var emails = event.getParam("CCEmails");
            component.set("v.manualCCRoleEmails", emails);
            helper.passChosenManualEmailsToFlow(flowStageOfSelection, emails);
        }

    },

    populateEmailTemplate: function(component, event) {
        var templateName = event.getParam("templateName");
        component.set("v.templateName", templateName);
    },

    populateFileNames: function(component, event) {
        var fileNames = event.getParam("fileNames");
        component.set("v.fileNames", fileNames);
    },

    updatePath: function(component, event) {
        var currentStage = event.getParam("currentStage");
        var activeSections = [currentStage];
        component.set("v.currentStage", currentStage);
        component.set("v.activeSections", activeSections);
    }

})