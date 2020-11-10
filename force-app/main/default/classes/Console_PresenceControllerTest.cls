/**
 * @file name          : Console_PresenceControllerTest.cls
 * @description        : Test class for the Console_PresenceController Lightning Controller.
 * @author             : simon.brule@intact.net
 * @group              : Lightning Controller - Apex Tests
 * @last modified by   : hugo-olivier.monette@intact.net
 * @last modified on   : 2020-03-06, 12:19:39 p.m.
 * @modification log   :
 * Ver       Date            Author              Modification
 * 1.0    2020-03-04   simon.brule@intact.net    Initial Version
 **/
@isTest
public class Console_PresenceControllerTest {
  private static final String USERROLE_DEVELOPERNAME_ONTARIO_AGENT = 'Ontario_Agent_EN';
  private static final String USERROLE_DEVELOPERNAME_QUEBEC_AGENT = 'Quebec_Agent_Bilingual';
  private static final String PROFILE_NAME_BELAIR_AGENT = 'Belair Agent User';
  private static Set<String> generatedUsernames = new Set<String>();

  private static User instantiateLiveChatAgentUser(
    Id roleId,
    Id profileId,
    String firstName,
    String lastName
  ) {
    
    Integer randomInt = Integer.valueOf(math.random() * 100000);
    String uniqueName = firstName + lastName + randomInt;

    while(generatedUsernames.contains(uniqueName)){
      randomInt = Integer.valueOf(math.random() * 100000);
      uniqueName = firstName + lastName + randomInt;
    }

    generatedUsernames.add(uniqueName);

    return new User(
      FirstName = firstName,
      LastName = lastName,
      ProfileId = profileId,
      UserRoleId = roleId,
      Email = uniqueName + '@intact.net',
      Username = uniqueName + '@test.org',
      UserPermissionsLiveAgentUser = true,
      EmailEncodingKey = 'ISO-8859-1',
      Alias = 'TU' + randomInt,
      TimeZoneSidKey = 'America/Los_Angeles',
      LocaleSidKey = 'en_US',
      LanguageLocaleKey = 'en_US'
    );
  }

  //This will probably be use in a library somewhere down the line.
  private static List<User> createBulkLiveChatAgentUsers(
    Id roleId,
    Id profileId,
    Integer count,
    Boolean isInsert
  ) {
    List<User> newUsers = new List<User>();
    
    for (Integer i = 0; i < count; i++) {
      newUsers.add(
        instantiateLiveChatAgentUser(
          roleId,
          profileId,
          'FirstName' + i,
          'LastName' + i
        )
      );
    }

    if (isInsert) {
      insert newUsers;
    }
    
    return newUsers;
  }

  @isTest
  private static void getLeveragedCapacityByAgentUserTest() {
    //As Of API 48 the use of DML for AgentWork is not supported.
    //This doesn't test anything it's only for coverage since we can't use DML for the needed object

    Id roleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_ONTARIO_AGENT
      LIMIT 1
    ][0]
    .Id;
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :PROFILE_NAME_BELAIR_AGENT
      LIMIT 1
    ][0]
    .Id;

    List<User> newUsers = createBulkLiveChatAgentUsers(roleId, profileId, 3, true);
    Map<Id, Double> capacityByAgent = Console_PresenceController.getLeveragedCapacityByAgentUser(
      newUsers
    );

    System.assertEquals(
      3,
      capacityByAgent.size(),
      'Wrong number of Agent with capacity'
    );
  }

  @isTest
  private static void getActiveUsersPresencesTest() {
    //As Of API 48 the use of DML for UserServicePresence is not supported.
    //This doesn't test anything it's only for coverage since we can't use DML for the needed object

    Id roleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_ONTARIO_AGENT
      LIMIT 1
    ][0]
    .Id;
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :PROFILE_NAME_BELAIR_AGENT
      LIMIT 1
    ][0]
    .Id;

    List<User> newUsers = createBulkLiveChatAgentUsers(roleId, profileId, 3, true);
    Map<Id, UserServicePresence> activeUserPresences = Console_PresenceController.getActiveUsersPresences(
      newUsers
    );

    System.assertEquals(
      0,
      activeUserPresences.size(),
      'Wrong number of active user'
    );
  }

  @isTest
  private static void getAgentUsersPresenceTestWithoutCache() {
    //As Of API 48 the use of DML for OmniChannel Object is not supported.
    //This doesn't test anything it's only for coverage since we can't use DML for the needed object

    Id roleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_ONTARIO_AGENT
      LIMIT 1
    ][0]
    .Id;
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :PROFILE_NAME_BELAIR_AGENT
      LIMIT 1
    ][0]
    .Id;

    Integer numberofUsers = [
      SELECT COUNT()
      FROM User
      WHERE UserPermissionsLiveAgentUser = true AND UserRoleId = :roleId
    ];

    User newUser = instantiateLiveChatAgentUser(
      roleId,
      profileId,
      'FirstName',
      'LastName'
    );

    insert newUser;

    // Since the query on user in test environment return all the user in the org
    // To compare we get the number of user before the insert and after the insert.
    System.runAs(newUser) {
      List<Console_PresenceController.UserPresence> userPresences = Console_PresenceController.getAgentUsersPresence();
      System.assertEquals(
        numberofUsers + 1,
        userPresences.size(),
        'Wrong number of user added to the Test environment'
      );
    }
  }

  @isTest
  private static void getAgentUsersPresenceTestWithCache() {
    //As Of API 48 the use of DML for OmniChannel Object is not supported.
    //This doesn't test anything it's only for coverage since we can't use DML for the needed object
    Id roleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_ONTARIO_AGENT
      LIMIT 1
    ][0]
    .Id;
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :PROFILE_NAME_BELAIR_AGENT
      LIMIT 1
    ][0]
    .Id;
    List<User> newUsers = createBulkLiveChatAgentUsers(roleId, profileId, 3, true);

    List<Console_PresenceController.UserPresence> userPresencesToAdd = new List<Console_PresenceController.UserPresence>{
      new Console_PresenceController.UserPresence('firstName', 'lastName')
    };

    Cache.OrgPartition cachePartititon = Cache.Org.getPartition(
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_NAMESPACE +
      '.' +
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_PARTITION
    );

    cachePartititon.put(
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_KEYROOT + roleId,
      userPresencesToAdd,
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_TTL
    );

    System.runAs(newUsers[0]) {
      List<Console_PresenceController.UserPresence> userPresencesRetrieved = Console_PresenceController.getAgentUsersPresence();
      System.assertEquals(
        1,
        userPresencesRetrieved.size(),
        'Did not return the cache'
      );
    }
  }

  @isTest
  private static void getCachedPresencesTest() {
    Id roleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_ONTARIO_AGENT
      LIMIT 1
    ][0]
    .Id;
    Console_PresenceController.AgentsPresenceCache presencesCache = new Console_PresenceController.AgentsPresenceCache(
      roleId,
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_NAMESPACE,
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_PARTITION,
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_KEYROOT
    );

    List<Console_PresenceController.UserPresence> userPresences = new List<Console_PresenceController.UserPresence>{
      new Console_PresenceController.UserPresence('firstName', 'lastName')
    };
    presencesCache.cache(
      userPresences,
      Console_PresenceController.ORG_SERVICECONSOLE_CACHE_TTL
    );

    System.assertEquals(
      true,
      presencesCache.hasCachedPresences(),
      'The cache has no presences'
    );
    System.assertEquals(
      1,
      presencesCache.getCachedPresences().size(),
      'The cache presences do not contain only 1 user'
    );
  }

  @isTest
  private static void userPresenceOfflineDefaultTest() {
    Console_PresenceController.UserPresence userPresence = new Console_PresenceController.UserPresence(
      'firstName',
      'lastName'
    );

    System.assertEquals('firstName lastName', userPresence.name, 'Wrong name');
    System.assertEquals('Offline', userPresence.label, 'Wrong label');
    System.assertEquals(
      Console_PresenceController.AGENT_PRESENCE_STATUS.OFFLINE.name(),
      userPresence.status,
      'Wrong status'
    );
    System.assertEquals(
      0,
      userPresence.availableCapacityPercentage,
      'Wrong capacity'
    );
  }

  @isTest
  private static void userPresenceCompleteTest() {
    Console_PresenceController.UserPresence userPresenceOnlineWithMax = new Console_PresenceController.UserPresence(
      'firstName',
      'lastName',
      false,
      'Online',
      100,
      75
    );
    Console_PresenceController.UserPresence userPresenceOfflineNoMax = new Console_PresenceController.UserPresence(
      'firstName',
      'lastName',
      true,
      'Offline',
      0,
      0
    );

    System.assertEquals(
      'firstName lastName',
      userPresenceOnlineWithMax.name,
      'Wrong name'
    );
    System.assertEquals(
      'Online',
      userPresenceOnlineWithMax.label,
      'Wrong label'
    );
    System.assertEquals(
      Console_PresenceController.AGENT_PRESENCE_STATUS.ONLINE.name(),
      userPresenceOnlineWithMax.status,
      'Wrong status'
    );
    System.assertEquals(
      25,
      userPresenceOnlineWithMax.availableCapacityPercentage,
      'Wrong capacity'
    );

    System.assertEquals(
      'firstName lastName',
      userPresenceOfflineNoMax.name,
      'Wrong name'
    );
    System.assertEquals(
      'Offline',
      userPresenceOfflineNoMax.label,
      'Wrong label'
    );
    System.assertEquals(
      Console_PresenceController.AGENT_PRESENCE_STATUS.AWAY.name(),
      userPresenceOfflineNoMax.status,
      'Wrong status'
    );
    System.assertEquals(
      0,
      userPresenceOfflineNoMax.availableCapacityPercentage,
      'Wrong capacity'
    );
  }

  /*
   *To test all the sort case that are in the compareTo method we create, sort and compare multiple different list.
   *The list with NoChange in the name are already in order. We test that they come back in the same order.
   *The list with Change needs to come back with the two value inverted.
   */
  @isTest
  private static void userPresenceCompareTest() {
    Console_PresenceController.UserPresence offlineUser = new Console_PresenceController.UserPresence(
      'Offline',
      'User'
    );
    Console_PresenceController.UserPresence onlineUser = new Console_PresenceController.UserPresence(
      'Online',
      'User',
      false,
      'Online',
      100,
      75
    );
    Console_PresenceController.UserPresence awayUser = new Console_PresenceController.UserPresence(
      'Away',
      'User',
      true,
      'Away',
      100,
      75
    );
    Console_PresenceController.UserPresence onlineUserWithMoreAvailability = new Console_PresenceController.UserPresence(
      'SecondOnline',
      'User',
      false,
      'Online',
      150,
      75
    );
    Console_PresenceController.UserPresence onlineUserAfterAlphabetically = new Console_PresenceController.UserPresence(
      'ThirdOnline',
      'User',
      false,
      'Online',
      100,
      75
    );
    Console_PresenceController.UserPresence onlineUserCopy = new Console_PresenceController.UserPresence(
      'ThirdOnline',
      'User',
      false,
      'Online',
      100,
      75
    );

    List<Console_PresenceController.UserPresence> userPresenceOnlineNoChange = new List<Console_PresenceController.UserPresence>();
    userPresenceOnlineNoChange.add(onlineUser);
    userPresenceOnlineNoChange.add(offlineUser);

    List<Console_PresenceController.UserPresence> userPresenceAwayChange = new List<Console_PresenceController.UserPresence>();
    userPresenceAwayChange.add(awayUser);
    userPresenceAwayChange.add(onlineUser);

    List<Console_PresenceController.UserPresence> userPresenceOfflineChange = new List<Console_PresenceController.UserPresence>();
    userPresenceOfflineChange.add(offlineUser);
    userPresenceOfflineChange.add(awayUser);

    List<Console_PresenceController.UserPresence> userPresenceOfflineNoChange = new List<Console_PresenceController.UserPresence>();
    userPresenceOfflineNoChange.add(awayUser);
    userPresenceOfflineNoChange.add(offlineUser);

    List<Console_PresenceController.UserPresence> userPresenceAvailableChange = new List<Console_PresenceController.UserPresence>();
    userPresenceAvailableChange.add(onlineUser);
    userPresenceAvailableChange.add(onlineUserWithMoreAvailability);

    List<Console_PresenceController.UserPresence> userPresenceAvailableNoChange = new List<Console_PresenceController.UserPresence>();
    userPresenceAvailableNoChange.add(onlineUserWithMoreAvailability);
    userPresenceAvailableNoChange.add(onlineUser);

    List<Console_PresenceController.UserPresence> userPresenceNameChange = new List<Console_PresenceController.UserPresence>();
    userPresenceNameChange.add(onlineUserAfterAlphabetically);
    userPresenceNameChange.add(onlineUser);

    List<Console_PresenceController.UserPresence> userPresenceNameNoChange = new List<Console_PresenceController.UserPresence>();
    userPresenceNameNoChange.add(onlineUser);
    userPresenceNameNoChange.add(onlineUserAfterAlphabetically);

    List<Console_PresenceController.UserPresence> userPresenceNoChange = new List<Console_PresenceController.UserPresence>();
    userPresenceNoChange.add(onlineUserAfterAlphabetically);
    userPresenceNoChange.add(onlineUserCopy);

    userPresenceOnlineNoChange.sort();
    userPresenceAwayChange.sort();
    userPresenceOfflineChange.sort();
    userPresenceOfflineNoChange.sort();
    userPresenceAvailableChange.sort();
    userPresenceAvailableNoChange.sort();
    userPresenceNameChange.sort();
    userPresenceNameNoChange.sort();
    userPresenceNoChange.sort();

    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        onlineUser,
        offlineUser
      },
      userPresenceOnlineNoChange,
      'The Online No Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{ onlineUser, awayUser },
      userPresenceAwayChange,
      'The Away Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        awayUser,
        offlineUser
      },
      userPresenceOfflineChange,
      'The Offline Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        awayUser,
        offlineUser
      },
      userPresenceOfflineNoChange,
      'The Offline No Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        onlineUserWithMoreAvailability,
        onlineUser
      },
      userPresenceAvailableChange,
      'The Availability Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        onlineUserWithMoreAvailability,
        onlineUser
      },
      userPresenceAvailableNoChange,
      'The Availability No Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        onlineUser,
        onlineUserAfterAlphabetically
      },
      userPresenceNameChange,
      'The Name Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        onlineUser,
        onlineUserAfterAlphabetically
      },
      userPresenceNameNoChange,
      'The Name No Change Sort did not work'
    );
    System.assertEquals(
      new List<Console_PresenceController.UserPresence>{
        onlineUserAfterAlphabetically,
        onlineUserCopy
      },
      userPresenceNoChange,
      'The No Change Sort did not work'
    );
  }

  /*
   * Since the query on user in test environment return all the user in the org
   * To compare we get the number of user before the insert and after the insert.
   */
  @isTest
  private static void getUserRoleIdTest() {
    Id roleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_ONTARIO_AGENT
      LIMIT 1
    ][0]
    .Id;
    Id roleIdTest = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :USERROLE_DEVELOPERNAME_QUEBEC_AGENT
      LIMIT 1
    ][0]
    .Id;
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :PROFILE_NAME_BELAIR_AGENT
      LIMIT 1
    ][0]
    .Id;

    Integer numberOfUsers = Console_PresenceController.getAllAgentUsersForRole(
        roleId
      )
      .size();
      
    User userOfflineAgent = instantiateLiveChatAgentUser(
      roleId,
      profileId,
      'FirstName',
      'LastName'
    );

    userOfflineAgent.UserPermissionsLiveAgentUser = false;

    List<User> newUsers = new List<User>{
      instantiateLiveChatAgentUser(roleId, profileId, 'FirstName', 'LastName'),
      instantiateLiveChatAgentUser(
        roleIdTest,
        profileId,
        'FirstName',
        'LastName'
      ),
      userOfflineAgent
    };

    insert newUsers;

    //The list of user was carefully created so only 1 more user would be return
    //even if we enter 3 new users. The other two don't have the right role or
    //the permission checbox if false.
    System.runAs(newUsers[0]) {
      System.assertEquals(
        numberOfUsers + 1,
        Console_PresenceController.getAllAgentUsersForRole(roleId).size(),
        'The Number of user added is wrong'
      );
    }
  }
}