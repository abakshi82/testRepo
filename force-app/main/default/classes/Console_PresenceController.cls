/**
 * @file name          : Console_PresenceController.cls
 * @description        : Provides information regarding Chat Agent Users' Presence.
 *  Is consummed by the "Console_DisplayPresence" Lightning Component.
 * @author             : hugo-olivier.monette@intact.net
 * @group              : Lightning Controller
 * @last modified by   : hugo-olivier.monette@intact.net
 * @last modified on   : 2020-02-27, 11:50:26 a.m.
 * @modification log   :
 * Ver       Date            Author                         Modification
 * 1.0    2020-02-27   hugo-olivier.monette@intact.net    Initial Version
 * 1.1    2020-03-04   simon.brule@intact.net             Added TestVisible Annotation
 **/
public without sharing class Console_PresenceController {
  @TestVisible
  private static final String ORG_SERVICECONSOLE_CACHE_KEYROOT = 'AgentPresences';
  @TestVisible
  private static final String ORG_SERVICECONSOLE_CACHE_NAMESPACE = 'local';
  @TestVisible
  private static final String ORG_SERVICECONSOLE_CACHE_PARTITION = 'ServiceAgents';
  @TestVisible
  private static final Integer ORG_SERVICECONSOLE_CACHE_TTL = 300;
  private static final String AGENTWORK_STATUS_OPEN = 'Opened';

  @TestVisible
   private enum AGENT_PRESENCE_STATUS {
    ONLINE,
    AWAY,
    OFFLINE
  }

  /**
   * @description Get a list of all Chat Agent Users which matches the current User's Role.
   *  The information includes the agents' statuses and capacity. See UserPresence wrapper for more info.
   * @author hmonette@deloitte.ca | 2/27/2020
   * @return List<UserPresence> A list of all Chat Agent Users presence information that matches the current User's Role
   **/
  @TestVisible
  @AuraEnabled
  public static List<UserPresence> getAgentUsersPresence() {
    try {
      AgentsPresenceCache presencesCache = new AgentsPresenceCache(
        UserInfo.getUserRoleId(),
        ORG_SERVICECONSOLE_CACHE_NAMESPACE,
        ORG_SERVICECONSOLE_CACHE_PARTITION,
        ORG_SERVICECONSOLE_CACHE_KEYROOT
      );

      if (presencesCache.hasCachedPresences()) {
        return presencesCache.getCachedPresences();
      }

      List<UserPresence> presences = new List<UserPresence>();
      List<User> agentUsers = getAllAgentUsersForRole(UserInfo.getUserRoleId());

      Map<Id, Double> userIdToLeveragedCapacity = getLeveragedCapacityByAgentUser(
        agentUsers
      );

      Map<Id, UserServicePresence> userIdToPresence = getActiveUsersPresences(
        agentUsers
      );

      for (User agent : agentUsers) {
        Boolean isAgentOnline = userIdToPresence.containsKey(agent.Id);
        Double agentLeveragedCapacity = userIdToLeveragedCapacity.get(agent.Id);
        UserServicePresence agentPresence = userIdToPresence.get(agent.Id);

        presences.add(
          isAgentOnline
            ? new UserPresence(
                agent.FirstName,
                agent.LastName,
                agentPresence.isAway,
                agentPresence.ServicePresenceStatus.MasterLabel,
                agentPresence.ConfiguredCapacity,
                agentLeveragedCapacity
              )
            : new UserPresence(agent.FirstName, agent.LastName)
        );
      }

      presences.sort();

      presencesCache.cache(presences, ORG_SERVICECONSOLE_CACHE_TTL);

      return presences;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  /**
   * @description Get active UserServicePresence entries, organized by Users' Id, for the provided Users list.
   * @author hmonette@deloitte.ca | 2/27/2020
   * @param agentUsers List of Users for which presence should be retrieved
   * @return Map<Id, UserServicePresence> Active Presence entries from the system, organized by User Id
   **/
  @TestVisible
  private static Map<Id, UserServicePresence> getActiveUsersPresences(
    List<User> agentUsers
  ) {
    Map<Id, UserServicePresence> userIdToPresence = new Map<Id, UserServicePresence>();

    for (UserServicePresence presence : [
      SELECT
        ServicePresenceStatus.MasterLabel,
        UserId,
        IsAway,
        ConfiguredCapacity
      FROM UserServicePresence
      WHERE IsCurrentState = true AND UserId IN :agentUsers
    ]) {
      userIdToPresence.put(presence.UserId, presence);
    }

    return userIdToPresence;
  }

  /**
   * @description Get a List of all User entries which are enabled for as Chat Agents
   *   and who matches the provided Role.
   * @author hmonette@deloitte.ca | 2020-02-27
   * @param roleId The Id of the target UserRole
   * @return List<User> List of chat Users matching the provided target UserRole
   **/
  @TestVisible
  private static List<User> getAllAgentUsersForRole(Id roleId) {
    return [
      SELECT Id, FirstName, LastName
      FROM User
      WHERE UserPermissionsLiveAgentUser = true AND UserRoleId = :roleId
    ];
  }
  /**
   * @description Get the leveraged (in-use) work items capacity for every given target User,
   *  organized by User Id. This is obtained by summing up the CapacityWeight of all active
   *  work items assigned to a given User.
   * @author hmonette@deloitte.ca | 2/27/2020
   * @param agentUsers List of agent Users for which leveraged capacity should be retrieved and calculated
   * @return Map<Id, Double> Map of agents' leveraged capacity organized by User Id
   **/
  @TestVisible
  private static Map<Id, Double> getLeveragedCapacityByAgentUser(
    List<User> agentUsers
  ) {
    Map<Id, Double> userIdToLeveragedCapacity = new Map<Id, Double>();

    for (User agent : agentUsers) {
      userIdToLeveragedCapacity.put(agent.Id, 0);
    }

    for (AgentWork work : [
      SELECT CapacityWeight, UserId
      FROM AgentWork
      WHERE Status = :AGENTWORK_STATUS_OPEN AND UserId IN :agentUsers
    ]) {
      Double leveragedCapacityRunningTotal = userIdToLeveragedCapacity.get(
        work.UserId
      );

      userIdToLeveragedCapacity.put(
        work.UserId,
        leveragedCapacityRunningTotal + work.CapacityWeight
      );
    }

    return userIdToLeveragedCapacity;
  }

  /**
   * Wrapper class representing a single Agent User's presence-related information.
   *  To be consummed by the frontend presence component.
   */
  @TestVisible
  private class UserPresence implements Comparable {
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public Double availableCapacityPercentage;

    /**
     * Name-Only constructor with defaulting, for offline Agents
     */
    public UserPresence(String firstname, String lastname) {
      this.name = firstname + ' ' + lastname;
      this.label = 'Offline';
      this.status = AGENT_PRESENCE_STATUS.OFFLINE.name();
      this.availableCapacityPercentage = 0;
    }

    /**
     * Full constructor, for online Agents
     */
    public UserPresence(
      String firstname,
      String lastname,
      Boolean isAway,
      String presenceLabel,
      Double maxcapacity,
      Double leveragedCapacity
    ) {
      this.name = firstname + ' ' + lastname;
      this.availableCapacityPercentage = maxcapacity == 0
        ? 0
        : Math.round(100 - ((leveragedCapacity / maxcapacity) * 100));
      this.status = (isAway
          ? AGENT_PRESENCE_STATUS.AWAY
          : AGENT_PRESENCE_STATUS.ONLINE)
        .name();
      this.label = presenceLabel;
    }

    /**
     * @description Default sorting method implementation for the Comparable interface.
     *   Sorting priority as Status > Availability % > Name (alphabetical)
     * @author hmonette@deloitte.ca | 2020-02-27
     * @param compareTo Other UserPresence instance to compare to the current
     * @return Integer The sorting order priority of the 2 instances being compared
     **/
    public Integer compareTo(Object compareTo) {
      UserPresence compareToPresence = (UserPresence) compareTo;

      // First sort by Status: Online > Away > Offline
      if (this.status != compareToPresence.status) {
        if (this.status == AGENT_PRESENCE_STATUS.OFFLINE.name()) {
          return 1;
        } else if (this.status == AGENT_PRESENCE_STATUS.ONLINE.name()) {
          return -1;
        } else if (this.status == AGENT_PRESENCE_STATUS.AWAY.name()) {
          if (compareToPresence.status == AGENT_PRESENCE_STATUS.ONLINE.name()) {
            return 1;
          } else if (
            compareToPresence.status == AGENT_PRESENCE_STATUS.OFFLINE.name()
          ) {
            return -1;
          }
        }
      }

      // Then sort by Availability %
      if (
        this.availableCapacityPercentage >
        compareToPresence.availableCapacityPercentage
      ) {
        return -1;
      } else if (
        this.availableCapacityPercentage <
        compareToPresence.availableCapacityPercentage
      ) {
        return 1;
      }

      // Finally Sort Alphabetically
      if (this.name > compareToPresence.name) {
        return 1;
      } else if (this.name < compareToPresence.name) {
        return -1;
      }

      return 0;
    }
  }

  /**
   * Wrapper & Utility class providing Platform Caching functionalities to a list of UserPresence instances.
   */
  @TestVisible
  private class AgentsPresenceCache {
    private Cache.OrgPartition cachePartititon;
    private List<UserPresence> presences;
    private final String cacheKey;

    /**
     * Constructor
     */
    public AgentsPresenceCache(
      String agentUserRoleId,
      String cacheNamespace,
      String cachePartitionName,
      String cacheKeyRootName
    ) {
      this.cachePartititon = Cache.Org.getPartition(
        cacheNamespace +
        '.' +
        cachePartitionName
      );
      this.cacheKey = cacheKeyRootName + agentUserRoleId;
      this.presences = (List<UserPresence>) cachePartititon.get(this.cacheKey);
    }

    /**
     * @description Determines whether this cache contains cached UserPresence information.
     *  Cache is inferred from null-state to minimize the amount of calls required to the Org Cache.
     * @author hmonette@deloitte.ca | 2020-02-27
     * @return Boolean Whether or not UserPresence data is available in the cache
     **/
    public Boolean hasCachedPresences() {
      return this.presences != null;
    }

    /**
     * @description Get the cached UserPresence entries.
     * @author hmonette@deloitte.ca | 2020-02-27
     * @return List<UserPresence> The cached UserPresence data
     **/
    public List<UserPresence> getCachedPresences() {
      return this.presences;
    }

    /**
     * @description Send the UserPresence list to cache, and set as this local cache instance's data.
     * @author hmonette@deloitte.ca | 2020-02-27
     * @param presences The UserPresence list to cache
     * @param cacheTTL The cache's Time to Live before it should be invalidated / cleared
     **/
    @TestVisible
    private void cache(List<UserPresence> presences, Integer cacheTTL) {
      this.presences = presences;

      this.cachePartititon.put(this.cacheKey, this.presences, cacheTTL);
    }
  }
}