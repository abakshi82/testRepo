window._GLOBAL = (function() {
    
    var claimId; 
    var exposureId; 
	var face;
    var time;
    var pig_en;
    var pig_fr;
    var language;
    
    return { //public API
        setClaimId: function(cId) {
            claimId = cId;
        },
        setExposureId: function(eId) {
            exposureId = eId;
        },
        setFace: function(fac) {
            face = fac;
        },
        setTime: function(tim) {
            time = tim;
        },
        setPig_en: function(pigen) {
            pig_en = pigen;
        },
        setPig_fr: function(pigfr) {
            pig_fr = pigfr;
        },
        setLanguage: function(lang) {
            language = lang;
        },
        getClaimId: function() {
            return claimId;
        },
        getExposureId: function() {
            return exposureId;
        },
        getFace: function() {
            return face;
        },
        getTime: function() {
            return time;
        },
        getPig_en: function() {
            return pig_en;
        },
        getPig_fr: function() {
            return pig_fr;
        },
        getLanguage: function() {
            return language; 
        }
    };
}());