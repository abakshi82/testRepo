/**
   * @Description: Selector for EmailFolder sObject
   * @Author:      Damian Kazior, PwC
   * @Date:        25/06/2019
*/
public with sharing class Omni_FolderSelector {

    public static Folder getFolderByName(String name){
        return [SELECT Id, Name
                FROM Folder
                WHERE Name =: name]; 
    }
    
	/**
    * @description Query List of Folders by Type
    * @author      Luis Merinero
    * @date        02/01/2020                     
    */
	public static List<Folder> getAllFoldersByType(String objectType){
        return [SELECT Id, Name
                FROM Folder
                WHERE Type =:objectType]; 
    } 
}