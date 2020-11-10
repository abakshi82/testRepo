({
    /**
     * @description Initializes Flow path with steps and current step defined on Flow
     * @author      Luis Merinero
     * @date        05/12/2019                     
     */
    init: function(component, event, helper) {
        var chevron = [$A.get("$Label.c.Omni_Adhoc_PrimaryRecipient"),
            $A.get("$Label.c.Omni_Adhoc_CCdRecipients"),
            $A.get("$Label.c.Omni_Adhoc_Exposure"),
            $A.get("$Label.c.Omni_Adhoc_EmailTemplate"),
            $A.get("$Label.c.Omni_Adhoc_Files")
        ];
        var progressIndicator = component.find('progressIndicator');
        console.log('currentStage:' + chevron);
        for (let step of chevron) {
            $A.createComponent(
                "lightning:progressStep", {
                    "aura:id": "step_" + step,
                    "label": step,
                    "value": step
                },
                function(newProgressStep, status, errorMessage) {
                    if (status === "SUCCESS") {
                        var body = progressIndicator.get("v.body");
                        body.push(newProgressStep);
                        progressIndicator.set("v.body", body);
                    } else if (status === "INCOMPLETE") {
                        console.log("No response from server, or client is offline.")
                    } else if (status === "ERROR") {
                        console.log("Error: " + errorMessage);
                    }
                }
            );
        }
    }
})