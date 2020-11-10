/**
   * @Description: Store response data from all Aura controllers in an organised fashion
   * @Author:      Damian Kazior, PwC
   * @Date:        25/06/2019
*/
public class Omni_AuraResponse {
    @AuraEnabled  public Integer code;
    @AuraEnabled  public Boolean success; 
    @AuraEnabled  public String  message; 
    @AuraEnabled  public sObject data; 
    @AuraEnabled  public List<Object> dataList;

    public Omni_AuraResponse(){
        this.dataList = new List<Object>(); 
    }

    public Omni_AuraResponse(Integer code, Boolean success, String message){
        this.code    = code;
        this.success = success;
        this.message = message; 
        this.dataList = new List<Object>(); 
    }
}