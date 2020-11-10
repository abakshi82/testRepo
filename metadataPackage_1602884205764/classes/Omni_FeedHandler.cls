/**
* @description handler to create FeedItem in auto notification flow
*              apply for Email/SMS/Print/Fax
* @author      Kejia Hu
* @date        09/20/2019              
*/
public with sharing class Omni_FeedHandler {

    private static List<FeedItem> feeds;

    /**
    * @description save FeedItems in salesforce apply for Email/SMS/Print/Fax
    * @author      Kejia Hu
    * @date        09/20/2019              
    */
    public static List<FeedItem> persistFeedItems(List<Omni_Feed> omniCommFeeds) {
        feeds = new List<FeedItem>();
        convertToFeedItems(omniCommFeeds);
        persistFeedItems();
        return feeds;
    }

    /**
    * @description convert Omni_Feed list to FeedItem list
    * @author      Kejia Hu
    * @date        09/20/2019              
    */
    private static void convertToFeedItems(List<Omni_Feed> omniCommFeeds) {
        for(Omni_Feed omniCommFeed :omniCommFeeds) {
            String channel = omniCommFeed.channel;
            feeds.add(convert(omniCommFeed));
        }
    }

    /**
    * @description convert Omni_Feed item to FeedItem item
    * @author      Kejia Hu
    * @date        09/20/2019              
    */
    private static FeedItem convert(Omni_Feed omniCommFeed) {
        FeedItem newFeed = new FeedItem();
        newFeed.ParentId = omniCommFeed.parentId;
        if (omniCommFeed.channel == Omni_ClaimEventConstant.COMM_CHANNEL_EMAIL) {
            newFeed.Body = generateFeedBodyForEmail(omniCommFeed);
        } else if (omniCommFeed.channel == Omni_ClaimEventConstant.COMM_CHANNEL_PRINT && String.isBlank(omniCommFeed.message)) {
            newFeed.Body = generateFeedBodyForPrintLetter(omniCommFeed);
        } else {
            newFeed.Body = omniCommFeed.generateFeedBody();
        }
        newFeed.Type = Omni_ClaimNotificationConstant.COMM_FEED_TYPE;
        newFeed.Status = Omni_ClaimNotificationConstant.COMM_FEED_STATUS;
        newFeed.Revision = 1;
        if (null != omniCommFeed.exposure && omniCommFeed.channel == Omni_ClaimNotificationConstant.COMM_CHANNEL_SMS) { 
            newFeed.Body += '\n' + 
                            System.Label.Omni_FeedMessageForSMS_EN + ' / '+ System.Label.Omni_FeedMessageForSMS_FR 
                            +'\n' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ omniCommFeed.recordId;
        } else if (omniCommFeed.channel == Omni_ClaimNotificationConstant.COMM_CHANNEL_SMS) {
            newFeed.Body += '\n' + 
                            System.Label.Omni_FeedMessageForSMSStatus_EN + ' / '+ System.Label.Omni_FeedMessageForSMSStatus_FR 
                            +'\n' + URL.getSalesforceBaseUrl().toExternalForm() +'/'+ omniCommFeed.recordId;
        }
        if (null != omniCommFeed.createdDate) {
            newFeed.CreatedDate = omniCommFeed.createdDate;
        }
        return newFeed;
    }

    /**
    * @description build email text feed based on Omni_Feed
    * @author      Kejia Hu
    * @date        09/20/2019              
    */
    private static String generateFeedBodyForPrintLetter(Omni_Feed omniCommFeed) {
        return String.format(System.Label.Omni_FeedBodyForPrint, new List<String>{
                                omniCommFeed.exposure
                                , URL.getSalesforceBaseUrl().toExternalForm()
                                , omniCommFeed.recordId
               }) + ' / ' + 
               String.format(System.Label.Omni_FeedBodyForPrint_FR, new List<String>{
                                omniCommFeed.exposure
                                , URL.getSalesforceBaseUrl().toExternalForm()
                                , omniCommFeed.recordId
               });
    }

    /**
    * @description build email text feed based on Omni_Feed
    * @author      Kejia Hu
    * @date        09/20/2019              
    */
    private static String generateFeedBodyForEmail(Omni_Feed omniCommFeed) {
        return String.format(System.Label.Omni_FeedBodyForEmail, new List<String>{
                                omniCommFeed.exposure
                                , URL.getSalesforceBaseUrl().toExternalForm()
                                , omniCommFeed.recordId
        });
    }

    /**
    * @description save FeedItems in salesforce
    * @author      Kejia Hu
    * @date        09/20/2019              
    */
    private static void persistFeedItems() {
        if(null != feeds && !feeds.isEmpty()) {
            insert feeds;
        }
    }
}