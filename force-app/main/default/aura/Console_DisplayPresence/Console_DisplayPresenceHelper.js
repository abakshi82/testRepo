({
  remote_getAgentUsersPresence: function(cmp) {
    return new Promise(function(resolve, reject) {
      var getUsersPresenceAction = cmp.get("c.getAgentUsersPresence");

      getUsersPresenceAction.setCallback(this, function(response) {
        if (response.getState() !== "SUCCESS") reject(response.getError()[0]);

        resolve(response.getReturnValue());
      });

      cmp.set("v.isCalloutInProgress", true);

      $A.enqueueAction(getUsersPresenceAction);
    });
  }
});