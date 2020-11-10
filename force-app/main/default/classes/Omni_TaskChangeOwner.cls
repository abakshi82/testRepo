public without sharing class Omni_TaskChangeOwner {

    @AuraEnabled
	public static Omni_AuraResponse changeOwner(String taskId) {

        Omni_AuraResponse auraResponse = new Omni_AuraResponse(); 
        auraResponse.success = true;
        try{
            if(taskId != null) {
                Task changetask = [SELECT OwnerId FROM Task WHERE Id = :taskId];
                if(changetask.OwnerId != UserInfo.getUserId()){
                    changetask.OwnerId = UserInfo.getUserId();
                    update changetask;
                    auraResponse.data = changetask;
                }
            }else{
                auraResponse.success = false;
            }
        }catch(Exception e){
            ApplicationLogHandler.addExceptionLog('Omni_TaskChangeOwner', e, null);
            auraResponse.success = false;
            auraResponse.message = e.getMessage();
        }
        return auraResponse; 
    }

}