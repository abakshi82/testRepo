/**
   * @Description: Selector for EmailTemplate sObject
   * @Author:      Damian Kazior, PwC
   * @Date:        25/06/2019
*/
public with sharing class Omni_EmailTemplateSelector {

    public static List<EmailTemplate> getAllEmailTemplates(){
        return [SELECT Id, Name, Subject, Body, HtmlValue
                FROM EmailTemplate];
    } 

    public static List<EmailTemplate> getAllEmailTemplatesByFolderName(String folderName){
        return [SELECT Id, Name, Subject, DeveloperName
                FROM EmailTemplate
                WHERE Folder.Name =:folderName]; 
    } 
    
    public static List<EmailTemplate> getAllEmailTemplatesByFolderNameAndLanguage(String folderName, String language){
        return [SELECT Id, Name, Subject
                FROM EmailTemplate
                WHERE Name LIKE :language AND (Folder.Name LIKE :folderName OR Folder.Name = 'Blank')];  
    }
	
    public static List<EmailTemplate> getBlankEmailTemplate(){
        return [SELECT Id, Name FROM EmailTemplate WHERE Name = 'EN_Blank' LIMIT 1]; 
    } 
}