({
    showConfirmMerge : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
        var masterCase = component.get("v.masterCaseRecord")
        var masterCaseId = (null != masterCase ) ? masterCase.CaseId : null; 
        if (null != masterCaseId) {
            component.set("v.hasMasterCase", true);
        }
        component.set("v.isMyCase", $A.get( "$SObjectType.CurrentUser.Id" ) === component.get("v.mergeCaseRecord").OwnerId);
    },
    
    cancelMerge : function(component, event, helper) {
        component.set('v.showConfirmDialog', false);
    },
    
    closeWorkMergeCases : function(component, event, helper) {
        var mergeCaseId = component.get("v.mergeCaseRecord").Id;
        var masterCaseId = component.get("v.masterCaseRecord").CaseId
        helper.showSpinnerWhileMerging(component, event);
        component.set("v.showConfirmDialog", false);
        var omniAPI = component.find("omniToolkit");
        omniAPI.getAgentWorks().then(function(result) {
            var works = JSON.parse(result.works);
            var i;
            if (works === undefined || works === null || works.length < 1 ) {
                helper.mergeCases(component, event, mergeCaseId, masterCaseId);
            } else {
                for (i = 0; i < works.length; i++) {
                    if(works[i].workItemId == mergeCaseId.substring(0, 15) || works[i].workItemId == masterCaseId.substring(0, 15)) {
                        var work = works[i];
                        omniAPI.closeAgentWork({workId: work.workId}).then(function(res) {
                            if (res) {
                                helper.mergeCases(component, event, mergeCaseId, masterCaseId); 
                            } else {
                                console.error($A.get("{!$Label.c.Omni_CaseMerge_Msg_CloseWorkFailed}"));
                            }
                        }).catch(function(error) {
                            console.error(error);
                        });
                    }
                }
            }
        }).catch(
            function(error) {
                console.log(error);
                helper.mergeCases(component, event, mergeCaseId, masterCaseId);
            }
        );
    }
})