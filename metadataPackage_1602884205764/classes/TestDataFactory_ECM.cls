@isTest
public class TestDataFactory_ECM {

    /**
    * @Description: Create File_Metadata__c
    * @Author:      Kejia Hu
    * @Date:        11/03/2020
    */
    public static File_Metadata__c createFileMetadata(String refId) {
        File_Metadata__c fMetadata = new File_Metadata__c();
        fMetadata.Reference_Id__c = refId;
        fMetadata.File_Mime_Type__c = 'ZIP';
        fMetadata.Count__c = 2;
        fMetadata.Processed_by_ECM__c = true;  
        fMetadata.File_Deleted__c = false;
        insert fMetadata;
        insert new ECM_Metadata__c(File_Metadata__c = fMetadata.Id);
        insert new ECM_Metadata__c(File_Metadata__c = fMetadata.Id);
        return fMetadata;
    }

    /**
    * @Description: Create ContentVersion
    * @Author:      Kejia Hu
    * @Date:        11/03/2020
    */
    public static ContentVersion createContentVersion() {
        ContentVersion contentVersionInsert = new ContentVersion(
            Title = 'Test',
            PathOnClient = 'Test.jpg',
            VersionData = Blob.valueOf('Test Content Data'),
            IsMajorVersion = true
        );
        insert contentVersionInsert;
        return contentVersionInsert;
    }

    /**
    * @Description: Create ContentDocumentLink
    * @Author:      Kejia Hu
    * @Date:        11/03/2020
    */
    public static ContentDocumentLink createContentDocumentLink(String parentId) {
        ContentVersion contentVersion = new ContentVersion(
                                                Title = 'Test CV',
                                                PathOnClient = 'cv.jpg',
                                                VersionData = Blob.valueOf('Test Content'),
                                                IsMajorVersion = true
                                                );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = parentId;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        return cdl;
    }
}