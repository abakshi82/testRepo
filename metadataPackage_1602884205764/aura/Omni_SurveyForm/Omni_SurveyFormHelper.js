({
    /**
     * @Description: Each survey will have GET parameters. Store these parameters in the component
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    fetchUrlParams: function(component, event, helper) {

        var sPageURL = decodeURIComponent(window.location.search.substring(1));
        //Split by & so that you get the key value pairs separately in a list
        var sURLVariables = sPageURL.split('&');
        var sParameterName;
        var i;
        if (_GLOBAL.getClaimId()) {
            console.log('ALREADY SET');
            return;
        }
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('=');

            if (sParameterName[0] == 'c_id') {
                _GLOBAL.setClaimId(sParameterName[1]);
            }
            if (sParameterName[0] == 'e_id') {
                _GLOBAL.setExposureId(sParameterName[1]);
            }
            if (sParameterName[0] == 'faceid') {
                _GLOBAL.setFace(sParameterName[1]);
            }
            if (sParameterName[0] == 'time') {
                _GLOBAL.setTime(sParameterName[1]);
            }
            if (sParameterName[0] == 'pig_fr') {
                _GLOBAL.setPig_fr(sParameterName[1]);
            }
            if (sParameterName[0] == 'pig_en') {
                _GLOBAL.setPig_en(sParameterName[1]);
            }
            if (sParameterName[0] == 'lang') {
                _GLOBAL.setLanguage(sParameterName[1]);
            }
        }
        this.navigate(component, event, helper);
    },

    storeParams: function(component, event, helper) {

        component.set("v.face", _GLOBAL.getFace());
        component.set("v.pig_fr", _GLOBAL.getPig_fr());
        component.set("v.pig_en", _GLOBAL.getPig_en());
        component.set("v.language", _GLOBAL.getLanguage());
    },

    navigate: function(component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"
        });
        urlEvent.fire();

    },

    getIsSitePreview: function(url) {
        var urlToCheck = url;
        if (!urlToCheck) {
            urlToCheck = window.location.hostname;
        }
        urlToCheck = urlToCheck.toLowerCase();
        return (urlToCheck.indexOf('sitepreview') >= 0 || urlToCheck.indexOf('livepreview') >= 0);
    },


    /**
     * @Description: Update Survey with comment (if there is one)
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    updateSurvey: function(component, event, helper) {

        component.set("v.showSpinner", true);
        var action = component.get("c.updateSurveyResults");
        action.setParams({
            'surveyId': component.get("v.surveyId"),
            'comment': component.find("comment-box").get('v.value')
        });

        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('resp' + storeResponse);
                component.set("v.showSpinner", false);
                component.set("v.showCommentForm", false);
            }
        });
        $A.enqueueAction(action);
    },

    /**
     * @Description: Create surve response object, as long as this customer did not answer the same survey already
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    validateAndCreateSurveyResult: function(component, event, helper) {

        var action = component.get("c.validateSurvey");
        action.setParams({
            'claimId': this.convert15To18(_GLOBAL.getClaimId()),
            'exposureId': this.convert15To18(_GLOBAL.getExposureId()),
            'timeStamp': _GLOBAL.getTime(),
            'faceId': _GLOBAL.getFace()
        });
        console.log('id::');
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('here');
                if (storeResponse.success) {
                    console.log(storeResponse);
                    component.set("v.isAlreadySubmitted", false);
                    component.set("v.surveyId", storeResponse.data.Id);
                } else {
                    component.set("v.isAlreadySubmitted", true);
                }
            } else {
                component.set("v.isAlreadySubmitted", true);
            }
            component.set("v.showSpinner", false);
        });
        $A.enqueueAction(action);
    },

    /**
     * @Description: Strings are displayed depending on GET lang parameter and not on user language choice. 
     *               Hence different language is displayed based on this method instead of translation workbench
     * @Author:      Damian Kazior, PwC
     * @Date:        12/01/2020
     */
    setTransaltedContent: function(component, event, helper) {
        if (_GLOBAL.getLanguage() == 'en') {
            component.set("v.LABEL_CannotRespondToSurveyAgain", $A.get("$Label.c.Omni_PulseSurvey_CannotRespondToSurveyAgain_EN"));
            component.set("v.LABEL_HeaderMessage", $A.get("$Label.c.Omni_PulseSurvey_Header_EN"));
            component.set("v.LABEL_Good_Description", $A.get("$Label.c.Omni_PulseSurvey_GoodDescription_EN"));
            component.set("v.LABEL_Soso_Description", $A.get("$Label.c.Omni_PulseSurvey_SosoDescription_EN"));
            component.set("v.LABEL_Awful_Description", $A.get("$Label.c.Omni_PulseSurvey_AwfulDescription_EN"));
            component.set("v.LABEL_Thank_You", $A.get("$Label.c.Omni_PulseSurvey_ThankYou_EN"));
            component.set("v.LABEL_Submit", $A.get("$Label.c.Omni_PulseSurvey_Submit_EN"));
            component.set("v.logo_url", _GLOBAL.getPig_en());

        } else {
            component.set("v.LABEL_CannotRespondToSurveyAgain", $A.get("$Label.c.Omni_PulseSurvey_CannotRespondToSurveyAgain_FR"));
            component.set("v.LABEL_HeaderMessage", $A.get("$Label.c.Omni_PulseSurvey_Header_FR"));
            component.set("v.LABEL_Good_Description", $A.get("$Label.c.Omni_PulseSurvey_GoodDescription_FR"));
            component.set("v.LABEL_Soso_Description", $A.get("$Label.c.Omni_PulseSurvey_SosoDescription_FR"));
            component.set("v.LABEL_Awful_Description", $A.get("$Label.c.Omni_PulseSurvey_AwfulDescription_FR"));
            component.set("v.LABEL_Thank_You", $A.get("$Label.c.Omni_PulseSurvey_ThankYou_FR"));
            component.set("v.LABEL_Submit", $A.get("$Label.c.Omni_PulseSurvey_Submit_FR"));
            component.set("v.logo_url", _GLOBAL.getPig_fr());
        }

    },
    convert15To18: function(idInput) {

        if (idInput.length == 15) {
            var addon = "";
            for (var block = 0; block < 3; block++) {
                var loop = 0;
                for (var position = 0; position < 5; position++) {
                    var current = idInput.charAt(block * 5 + position);
                    if (current >= "A" && current <= "Z")
                        loop += 1 << position;
                }
                addon += "ABCDEFGHIJKLMNOPQRSTUVWXYZ012345".charAt(loop);
            }
            idInput = idInput + addon;
        }
        return idInput;
    },
})