/**
* @author      Dan Goldberg
* @date        06-Dec-2019 
* @description Test class for PostSnapshotToChatter class
* <p>                                                                        
* 06-Dec-2019  - Dan Goldberg - creation and inital commit                        
*/

@isTest
public class PostSnapshotToChatterTest {
    
    public static  final String RESPONSEBODY  = 'Success';  
    
    @isTest 
    private static void PostSnapshotToChatterPositive() {
		Integer originalChatterFeed = [SELECT count() from FeedItem];
        Test.startTest();
        String reportId;
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ReportAttachmentControllerMockGenerator(201, 'Success', true, RESPONSEBODY));         
        PostSnapshotToChatter.postToChatter();   
        String expectedValue = RESPONSEBODY;
        FeedItem f = new FeedItem();
        f.Body = 'Dashboard_Snapshot';
        CollaborationGroup obj = new CollaborationGroup(name='dashboardSnapshotTest', CollaborationType = 'Public');
        insert obj;                                                
        f.parentid = obj.id;                                    
        insert f;
        Integer newChatterFeed = [SELECT count() from FeedItem];
        Test.StopTest();    
        System.assertEquals(originalChatterFeed + 1, newChatterFeed , 'One Chatter Item');    
    }
    
    @isTest 
    private static void PostSnapshotToChatterNegative() {        
       Integer originalChatterFeed = [SELECT count() from FeedItem];
        Test.startTest();
        String reportId;
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new ReportAttachmentControllerMockGenerator(401, 'Fail', true, RESPONSEBODY));         
        String expectedValue = RESPONSEBODY;
        Integer newChatterFeed = [SELECT count() from FeedItem];
        Test.StopTest();    
        System.assertEquals(originalChatterFeed, newChatterFeed , 'No new Chatter Item');
    
    }
    
    @isTest 
    private static void TestScheduledSnapshot() {
        Test.startTest();
        PostSnapshotToChatter sched = new PostSnapshotToChatter();
        string sch = '0 0 2 * * ?';
        String jobId = System.schedule('Test Scheduled PostSnapshot call.', sch, sched);
        test.stopTest();
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        System.assertEquals(sch, ct.CronExpression);
    }

}