({
  initialize: function(cmp, evt, helper) {
    var refreshUserPresence = $A.getCallback(function() {
      helper
        .remote_getAgentUsersPresence(cmp)
        .then(function(usersPresence) {
          cmp.set("v.usersPresence", usersPresence);
        })
        .catch(function(error) {
          //* Non-critical feature. Fail in silence. Simply clear the display.
          console.error(
            "Error Occurred with the Console Display Presence Component - ",
            error
          );

          cmp.set("v.usersPresence", null);
        })
        .finally(function() {
          cmp.set("v.isCalloutInProgress", false);

          if (cmp.get("v.interval")) return;

          cmp.set("v.interval", setInterval(refreshUserPresence, 60000));
        });
    });

    refreshUserPresence();
  }
});