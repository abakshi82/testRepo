/**
 * @Description: schedualable job to execute purge all Shadow Role case records batch job
 * 				 Code sample for Schedule t 5:25AM on the 15th day of every month
 *               System.schedule('Purge Shadow roles', '0 25 5 15 * ?', new PurgeShadowRoleSchedule());
 * @author:      Kejia Hu
 * @Date:        24-09-2019
 */
public class PurgeShadowRoleSchedule implements Schedulable {
    
    public void execute(SchedulableContext sc){
        Integer purgeDays = Integer.valueOf(Utility.CLAIM_NOTIF_CONFIG_BY_NAME.get('ShadowRolePurgeDays'));
        Database.executeBatch(new PurgeShadowRoleBatch(purgeDays), 2000);
    }
}