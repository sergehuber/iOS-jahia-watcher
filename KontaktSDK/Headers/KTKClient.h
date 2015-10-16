//
//  KTKClient.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 12/03/14.
//  Copyright (c) 2014 kontakt.io. All rights reserved.
//

#import "KTKVenue.h"
#import "KTKDevice.h"


@class KTKAction;
@class KTKPublicAction;
@class KTKBeacon;
@class KTKEddystone;
@class KTKCloudBeacon;
@class KTKPublicBeacon;
@class KTKBeaconProfile;
@class KTKFirmware;
@class KTKPublicVenue;
@class KTKManager;
@class KTKUser;

@class KTKPagingBeacons;
@class KTKPagingDevices;
@class KTKPagingConfigs;
@class KTKPagingVenues;

@protocol KTKAction;
@protocol KTKBeacon;

extern NSString *const kKTKAdded;
extern NSString *const kKTKModified;
extern NSString *const kKTKDeleted;
extern NSString *const kKTKTimestamp;


/**
 Social Media(access token) Provider Type
 */
typedef NS_ENUM(NSUInteger, KTKSocialProviderType)
{
    /**
     Social token provider type NONE
     */
    KTKSocialProviderTypeNone       = 0,
    /**
     Social token provider type Facebook
     */
    KTKSocialProviderTypeFacebook   = 1,
    /**
     Social token provider type Google
     */
    KTKSocialProviderTypeGoogle     = 2,
    /**
     Social token provider type Github
     */
    KTKSocialProviderTypeGithub     = 3
};

/**
 KTKClinet provides easy way to use web API methods.
 */
@interface KTKClient : NSObject

#pragma mark - properties

/**
 Authenticates user. You should write your own API key to this property.
 */
@property (copy, nonatomic, readwrite) NSString *apiKey;

/**
 Authenticates user by social media access token. Provide MUST be specified.
 */
@property (nonatomic, readonly) NSString *socialToken;

/**
 Type of social media from which is provided access token.
 */
@property (nonatomic, readonly) KTKSocialProviderType socialProviderType;

/**
 Points to the server where web API is located. You should not change value of this property.
 */
@property (copy, nonatomic, readwrite) NSURL *apiUrl;


#pragma mark - Public Setters

/**
 Sets social token and it's provider type - those two things work ONLY when they are both set
 Current socials: Facebook, Google, Github
 
 @param socialToken         token provided by one of social medias
 @param socialProviderType  type of social media that is provider of token
 
 @return nothing
 */
- (void)setSocialToken:(NSString *)socialToken andSocialProviderType:(KTKSocialProviderType)socialProviderType;


#pragma mark - Management


/**
 Returns regions that are used by KTKLocationManager to detect beacons.
 
 @warning   Don't use it - DEPRECATED
 @see       - (NSArray *)regionsWithError:(NSError **)error
 
 @param error error if operation fails
 
 @return array of KTKRegion objects
 */
- (NSArray *)getRegionsError:(NSError **)error __deprecated_msg("Use (NSArray *)regionsWithError:(NSError **)error");

/**
 Returns proximities(NSString objects) that can be used to initialize KTKRegion object
 
 @param error error if operation fails
 
 @return list of proximities
 */
- (NSArray *)proximitiesWithError:(NSError **)error;

/**
 Returns regions(KTKRegion objects) that are used by KTKLocationManager to monitor them and range beacons inside.
 
 @param error error if operation fails
 
 @return list of regions
 */
- (NSArray *)regionsWithError:(NSError **)error;


#pragma mark - Changelog


/**
 Returns venues that were added, changed or deleted since provided point in time.
 
 Return value is a dictionary that contains four keys:
 
 * kKTKAdded - array of added venues
 * kKTKModified - array of modified venues
 * kKTKDeleted - array of deleted venues
 * kKTKTimestamp - current server timestamp
 
 @warning   Don't use it - DEPRECATED
 @see       venuesWithError:
 
 @param since point in time, put 0 to get all venues
 @param error error if operation fails
 @return dictionary of KTKVenue objects
 */
- (NSDictionary *)getVenuesChangedSince:(NSUInteger)since error:(NSError **)error __deprecated_msg("Use - (NSArray *)venuesWithError:(NSError **)error");

/**
 Returns venues assigned to a venue that were added, changed or deleted since provided point in time.
 
 Return value is a dictionary that contains four keys:
 
 * kKTKAdded - array of added beacons
 * kKTKModified - array of modified beacons
 * kKTKDeleted - array of deleted beacons
 * kKTKTimestamp - current server timestamp
 
 @warning   Don't use it - DEPRECATED
 @see       beaconsWithError:
 
 @param venues venues array for which get beacons
 @param since point in time, put 0 to get all beacons
 @param error error if operation fails
 @return dictionary of KTKBeacon objects
 */
- (NSDictionary *)getBeaconsForVenues:(NSArray *)venues changedSince:(NSUInteger)since error:(NSError **)error __deprecated_msg("Use - (NSArray *)beaconsWithError:(NSError **)error");

/**
 Returns actions assigned to a beacon that were added, changed or deleted since provided point in time.
 
 Return value is a dictionary that contains four keys:
 
 * kKTKAdded - array of added actions
 * kKTKModified - array of modified actions
 * kKTKDeleted - array of deleted actions
 * kKTKTimestamp - current server timestamp
 
 @warning   Don't use it - DEPRECATED
 @see       actionByUUID:withError:
 
 @param beacons beacons array(KTKBeacon object(s)) for which get actions
 @param since point in time, put 0 to get all actions
 @param error error error if operation fails
 @return dictionary of KTKAction objects
 */
- (NSDictionary *)getActionsForBeacons:(NSArray *)beacons changedSince:(NSUInteger)since error:(NSError **)error __deprecated_msg("Use - (KTKAction *)actionByUUID:(NSString *)UUID withError:(NSError **)error");


#pragma mark - Action


/**
 Returns action object for specified UUID
 
 @param UUID    action's UUID
 @param error   error if operation fails
 
 @return action object
 */
- (KTKAction *)actionByUUID:(NSString *)UUID withError:(NSError **)error;

/**
 Returns content's bytes data for specified action's UUID.
 Data can be image or video(content action) or nil(browser action)
 
 @param UUID    action's UUID
 @param error   error if operation fails
 
 @return bytes that represents image/video
 */
- (NSData *)actionContentDataByUUID:(NSString *)UUID withError:(NSError **)error;

/**
 Returns boolean value which tells if CREATE operation succeeded
 
 @param action  action that we want to add/create
 @param error   error if operation fails
 
 @return TRUE if action was successfully created or FALSE if not
 */
- (BOOL)actionCreate:(KTKAction *)action withError:(NSError **)error;

/**
 Returns boolean value which tells if DELETE operation succeeded
 
 @param UUID    action's UUID that will be deleted
 @param error   error if operation fails
 
 @return BOOL value TRUE if action was successfully deleted or FALSE if not
 */
- (BOOL)actionDeleteByUUID:(NSString *)UUID withError:(NSError **)error;


#pragma mark - Beacon


/**
 Returns beacon which is related to specified unique ID
 
 @param uniqueID    beacon's unique ID - the one which contains 4 characters e.g. "AwA1"
 @param error       error if operation fails
 
 @return beacon object
 */
- (KTKBeacon *)beaconByUniqueID:(NSString *)uniqueID withError:(NSError **)error;

/**
 Returns array of beacons which are the properties of manager whose Api-Key is provided
 
 @param error error if operation fails
 
 @return array of beacons(KTKBeacon objects)
 */
- (NSArray *)beaconsWithError:(NSError **)error;

/**
 Returns array of beacons which are the properties of manager whose API-Key is provided
 
 @param paging  object which determines set of data that should be returned
 @param error   error if operation fails
 
 @return array of beacons(KTKBeacon objects)
 */
- (NSArray *)beaconsPaged:(KTKPagingBeacons *)paging withError:(NSError **)error;

/**
 Returns array of beacons which are the properties of manager with indicated UUID
 
 @warning   Don't use it - DEPRECATED
 @see       beaconsByManagerUUID:withError:
 
 @param managerUUID manager's UUID
 @param error       error if operation fails
 
 @return array of beacons
 */
- (NSArray *)getBeaconsByManagerUUID:(NSString *)managerUUID withError:(NSError **)error __deprecated_msg("Use - (NSArray *)beaconsByManagerUUID:(NSString *)managerUUID withError:(NSError **)error");

/**
 Returns array of beacons which are the properties of manager with indicated UUID
 
 @param managerUUID manager's UUID
 @param error       error if operation fails
 
 @return array of beacons
 */
- (NSArray *)beaconsByManagerUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Returns array of beacons which are the properties of indicated manager
 
 @warning   Don't use it - DEPRECATED
 @see       beaconsForManager:withError:
 
 @param manager manager
 @param error   error if operation fails

 @return array of beacons
 */
- (NSArray *)getBeaconsForManager:(KTKManager *)manager withError:(NSError **)error __deprecated_msg("Use - (NSArray *)beaconsForManager:(KTKManager *)manager withError:(NSError **)error");

/**
 Returns array of beacons which are the properties of indicated manager
 
 @param manager manager
 @param error   error if operation fails
 
 @return array of beacons
 */
- (NSArray *)beaconsForManager:(KTKManager *)manager withError:(NSError **)error;

/**
 Returns list of beacons which are the properties of indicated managers
 
 @warning   Don't use it - DEPRECATED
 @see       beaconsForManagers:withError:
 
 @param managers    list of managers
 @param error       error if operation fails

 @return list of beacons
 */
- (NSArray *)getBeaconsForManagers:(NSArray *)managers withError:(NSError **)error __deprecated_msg("Use - (NSArray *)beaconsForManagers:(NSArray *)managers withError:(NSError **)error");

/**
 Returns list of beacons which are the properties of indicated managers
 
 @param managers    list of managers
 @param error       error if operation fails
 
 @return list of beacons
 */
- (NSArray *)beaconsForManagers:(NSArray *)managers withError:(NSError **)error;

/**
 Returns beacon for specified UUID, major, minor and published parameteres.
 It can be used as PUBLIC(with public API key) and has the same effect as used with private/user's API key and isPublished = true
 
 @param UUID    beacon's proximity UUID
 @param major   beacon's major number
 @param minor   beacon's minor number
 @param isPublished boolean value which tells if beacon is publicly accessible
 @param error   error if operation fails
 
 @return KTKBeacon object
 */
- (KTKBeacon *)beaconByUUID:(NSString *)UUID major:(NSNumber *)major minor:(NSNumber *)minor published:(BOOL)isPublished withError:(NSError **)error;

/**
 Returns beacon for specified UUID, major and minor parameteres. 
 Has the same effect as similiar/above method with isPublished = false.
 It can be used as PUBLIC(with public API key).
 
 @param UUID    beacon's proximity UUID
 @param major   beacon's major number
 @param minor   beacon's minor number
 @param error   error if operation fails
 
 @return KTKBeacon object
 */
- (KTKBeacon *)beaconByUUID:(NSString *)UUID major:(NSNumber *)major minor:(NSNumber *)minor withError:(NSError **)error;

/**
 Returns password and master password for beacon with specified uniqueID.
 
 @warning   Don't use it - DEPRECATED
 @see       beaconPassword:andMasterPassword:byUniqueId:withError:
 
 @param password contains password after operation ends
 @param masterPassword contains master password after operation ends
 @param uniqueID uniqueID of beacon
 
 @return error if operation fails
 */
- (NSError *)getPassword:(NSString **)password andMasterPassword:(NSString **)masterPassword forBeaconWithUniqueID:(NSString *)uniqueID __deprecated_msg("Use - (BOOL)beaconPassword:(NSString **)password andMasterPassword:(NSString **)masterPassword byUniqueId:(NSString *)beaconUniqueId withError:(NSError **)error");

/**
 Gets beacon's password and master password(credentials) by specified unique Id
 
 @param password        beacon's password
 @param masterPassword  beacon's master password
 @param beaconUniqueId  beacon's unique Id
 @param error           error if operation fails
 
 @return YES if getting passwords succeed and NO if not
 */
- (BOOL)beaconPassword:(NSString **)password andMasterPassword:(NSString **)masterPassword byUniqueId:(NSString *)beaconUniqueId withError:(NSError **)error;

/**
 Sends information about beacon to the cloud.
 
 @warning   Don't use it - DEPRECATED
 @see       beaconUpdate:withError:
 
 @param beacon beacon to be saved
 
 @return error if operation fails
 */
- (NSError *)saveBeacon:(id<KTKBeacon>)beacon __deprecated_msg("Use - (BOOL)beaconUpdate:(KTKBeacon *)beacon withError:(NSError **)error");

/**
 Updates beacon properties according to it's uniqueID(required)
 
 @warning   Don't use it - DEPRECATED
 @see       beaconUpdate:withError:
 
 @param beacon  beacon object which represents current beacon's state
 @param error   error if operation fails
 
 @return YES if update succeed and NO if not
 */
- (BOOL)updateBeacon:(KTKBeacon *)beacon withError:(NSError **)error __deprecated_msg("Use - (BOOL)beaconUpdate:(KTKBeacon *)beacon withError:(NSError **)error");

/**
 Updates beacon properties according to it's uniqueID(required)
 
 @param beacon  beacon object which represents current beacon's state
 @param error   error if operation fails
 
 @return YES if update succeed and NO if not
 */
- (BOOL)beaconUpdate:(KTKBeacon *)beacon withError:(NSError **)error;

/**
 Assigns beacons to specified by UUID venue
 
 @param beacons     array of beacons(KTKBeacon objects) to be assigned to venue
 @param venueUUID   venue's UUID to which beacons will be assigned
 @param error       error if operation fails
 
 @return BOOL value TRUE if beacons were successfully assigned or FALSE if not
 */
- (BOOL)beacons:(NSArray *)beacons assignToVenueByUUID:(NSString *)venueUUID withError:(NSError **)error;

/**
 Assigns beacons to specified by UUID manager
 
 @param beacons     array of beacons(KTKBeacon objects) to be assigned to venue
 @param managerUUID manager's UUID to who beacons will be assigned
 @param error       error if operation fails
 
 @return BOOL value TRUE if beacons were successfully assigned or FALSE if not
 */
- (BOOL)beacons:(NSArray *)beacons assignToManagerByUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Move beacons to specified by UUID manager from Company(specified by UUID as well)
 
 @param beacons     array of beacons(KTKBeacon objects) to be assigned to venue
 @param managerUUID manager's UUID to who beacons will be assigned
 @param companyUUID comapny's UUID to which beacons will be assigned
 @param error       error if operation fails
 
 @return BOOL value TRUE if beacons were successfully assigned or FALSE if not
 */
- (BOOL)beacons:(NSArray *)beacons moveToManagerByUUID:(NSString *)managerUUID fromCompanyByUUID:(NSString *)companyUUID withError:(NSError **)error;

/**
 Returns array of manager's(specified by UUID) unassigned beacons
 
 @param managerUUID manager's UUID who has those unassigned beacons
 @param error       error if operation fails
 
 @return array of unassigned beacons
 */
- (NSArray *)beaconsUnassignedByManagerUUID:(NSString *)managerUUID withError:(NSError **)error;


#pragma mark - Device


/**
 Returns device which matches requested Unique ID
 
 @param uniqueID    device's unique ID
 @param error       error if operation fails
 
 @return device(KTKBeacon, KTKEddystone, KTKCloudBeacon) or nil
 */
- (id)deviceByUniqueID:(NSString *)uniqueID withError:(NSError **)error;

/**
 Returns device which matches requested proximity UUID, major and minor - all parameters are REQUIRED
 
 @param proximityUUID   device's proximity UUID
 @param major           device's major value
 @param minor           device's minor value
 @param error           error if operation fails
 
 @return device(KTKBeacon or KTKCloudBeacon) or nil
 */
- (id)deviceByProximityUUID:(NSString *)proximityUUID major:(NSNumber *)major andMinor:(NSNumber *)minor withError:(NSError **)error;

/**
 Returns array of devices which are the properties of manager definied by UUID and they match requested type
 
 @param managerUUID manager's UUID who is the owner of devices
 @param deviceType  describes which (type of) devices should be returned
 @param error       error if operation fails
 
 @return array of devices(KTKBeacon or KTKCloudBeacon objects)
 */
- (NSArray *)devicesByManagerUUID:(NSString *)managerUUID andType:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Returns array of devices which are the properties of manager(by UUID) and they match requested type and profile
 
 @param managerUUID     manager's UUID who is the owner of devices
 @param deviceType      describes which (type of) devices should be returned
 @param deviceProfile   describes desired devices profile
 @param error           error if operation fails
 
 @return array of devices(KTKBeacon, KTKEddystone, KTKCloudBeacon objects)
 */
- (NSArray *)devicesByManagerUUID:(NSString *)managerUUID
                          andType:(KTKDeviceType)deviceType
                       andProfile:(KTKDeviceProfile)deviceProfile
                        withError:(NSError **)error;

/**
 Returns array of devices which are the properties of current(by API-Key) manager and they match requested type
 
 @param deviceType  describes which (type of) devices should be returned
 @param error       error if operation fails
 
 @return array of devices(KTKBeacon or KTKCloudBeacon objects)
 */
- (NSArray *)devicesByType:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Returns set(paged) of devices which are the properties of manager definied by UUID and they match requested type
 
 @param paging      object which determines set of device that will be returned
 @param managerUUID manager's UUID who is the owner of devices
 @param deviceType  describes which (type of) devices should be returned
 @param error       error if operation fails
 
 @return array of devices(KTKBeacon or KTKCloudBeacon objects)
 */
- (NSArray *)devicesPaged:(KTKPagingDevices *)paging byManagerUUID:(NSString *)managerUUID andType:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Returns set(paged) of devices which are the properties of manager definied by UUID and they match requested type
 
 @param paging          object which determines set of device that will be returned
 @param managerUUID     manager's UUID who is the owner of devices
 @param deviceType      describes which (type of) devices should be returned
 @param deviceProfile   describes with which profile devices should be returned
 @param error           error if operation fails
 
 @return array of devices(KTKBeacon, KTKEddystone, KTKCloudBeacon objects)
 */
- (NSArray *)devicesPaged:(KTKPagingDevices *)paging
            byManagerUUID:(NSString *)managerUUID
                  andType:(KTKDeviceType)deviceType
               andProfile:(KTKDeviceProfile)deviceProfile
                withError:(NSError *__autoreleasing *)error;

/**
 Returns set(paged) of devices which are the properties of current(by API-Key) manager and they match requested type
 
 @param paging      object which determines set of device that will be returned
 @param deviceType  describes which (type of) devices should be returned
 @param error       error if operation fails
 
 @return array of devices(KTKBeacon or KTKCloudBeacon objects)
 */
- (NSArray *)devicesPaged:(KTKPagingDevices *)paging byType:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Updates device(Beacon, Eddystone or CloudBeacon) properties according to it's uniqueID(required)
 
 @param device  device object(KTKBeacon, KTKEddystone or KTKCloudBeacon) with new properties
 @param error   error if operation fails
 
 @return YES if update succeed and NO if not
 */
- (BOOL)deviceUpdate:(id)device withError:(NSError **)error;

/**
 Assigns device to manager - within the same company
 
 @param deviceUUID  device's UUID
 @param managerUUID manager's UUID who will be new owner of device
 @param error       error if operation fails
 
 @return YES if update succeed and NO if not
 */
- (BOOL)deviceAssignByUUID:(NSString *)deviceUUID toManagerByUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Assigns device to venue - within the same company
 
 @param deviceUUID  device's UUID
 @param venueUUID   venue's UUID to which device will be assigned
 @param error       error if operation fails
 
 @return YES if update succeed and NO if not
 */
- (BOOL)deviceAssignByUUID:(NSString *)deviceUUID toVenueByUUID:(NSString *)venueUUID withError:(NSError **)error;

/**
 Gets device's password and master password(credentials) by specified unique Id
 
 @param password        device's password
 @param masterPassword  device's master password
 @param deviceUniqueId  device's unique Id
 @param error           error if operation fails
 
 @return YES if getting passwords succeed and NO if not
 */
- (BOOL)devicePassword:(NSString **)password andMasterPassword:(NSString **)masterPassword byUniqueId:(NSString *)deviceUniqueId withError:(NSError **)error;

/**
 Moves device's ownership to manager(specified by his/her UUID) from different company
 
 @param uniqueId    device's unique Id
 @param managerUUID manager's UUID
 @param error       error if operation fails
 
 @return YES if moving device succeed and NO if not
 */
- (BOOL)deviceMoveByUniqueId:(NSString *)uniqueId toManagerByUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Moves device's ownership to manager(specified by his/her UUID) from different company(also by UUID)
 
 @param uniqueId    device's unique Id
 @param managerUUID manager's UUID
 @param companyUUID company's UUID - OPTIONAL
 @param error       error if operation fails
 
 @return YES if moving device succeed and NO if not
 */
- (BOOL)deviceMoveByUniqueId:(NSString *)uniqueId toManagerByUUID:(NSString *)managerUUID fromCompanyByUUID:(NSString *)companyUUID withError:(NSError **)error;

/**
 Moves devices' ownership to manager(specified by his/her UUID) from different company
 
 @param devicesUniqueIds    array of devices' unique Ids(NSStrings)
 @param managerUUID         manager's UUID
 @param error               error if operation fails
 
 @return YES if moving devices succeed and NO if not
 */
- (BOOL)devicesMove:(NSArray *)devicesUniqueIds toManagerByUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Moves devices' ownership to manager(specified by his/her UUID) from different company(also by UUID)
 
 @param devicesUniqueIds    array of devices' unique Ids(NSStrings)
 @param managerUUID         manager's UUID
 @param companyUUID         company's UUID - OPTIONAL
 @param error               error if operation fails
 
 @return YES if moving devices succeed and NO if not
 */
- (BOOL)devicesMove:(NSArray *)devicesUniqueIds toManagerByUUID:(NSString *)managerUUID fromCompanyByUUID:(NSString *)companyUUID withError:(NSError **)error;

/**
 Returns set of manager's(by UUID) devices specified by type which are unassigned to any venue
 
 @param managerUUID manager's UUID
 @param deviceType  describes which (type of) devices should be returned
 @param error       error if operation fails
 
 @return array of unassigned devices(KTKBeacon or KTKCloudBeacon objects)
 */
- (NSArray *)devicesUnassignedByManagerUUID:(NSString *)managerUUID andType:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Returns paged set of manager's(by UUID) devices specified by type which are unassigned to any venue
 
 @param paging      object which determines set of data that should be returned
 @param managerUUID manager's UUID
 @param deviceType  describes which (type of) devices should be returned
 @param error       error if operation fails
 
 @return array of unassigned devices(KTKBeacon or KTKCloudBeacon objects)
 */
- (NSArray *)devicesUnassignedPaged:(KTKPagingDevices *)paging byManagerUUID:(NSString *)managerUUID andType:(KTKDeviceType)deviceType withError:(NSError **)error;


#pragma mark - Configs


/**
 Returns list of devices(their new configs) that requires configuration.
 
 @param deviceType  determines for which type of devices will be getting new configs
 @param error       error if operation fails
 
 @warning without paging you can get only first 50 configs
 
 @return list of KTKBeacon/KTKCloudBeacon objects
 */
- (NSArray *)configsForDevices:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Returns list of devices(their new configs) that requires configuration.
 
 @param paging      object which determines set of data that should be returned
 @param deviceType  determines for which type of devices will be getting new configs
 @param error       error if operation fails
 
 @warning This method is not returning KTKEddystone objects
 
 @return list of KTKBeacon/KTKCloudBeacon objects
 */
- (NSArray *)configsPaged:(KTKPagingConfigs *)paging forDevices:(KTKDeviceType)deviceType withError:(NSError **)error;

/**
 Returns list of devices(their new configs) that requires configuration.
 
 @param paging          object which determines set of data that should be returned
 @param deviceType      determines for which device type configs will be returned
 @param deviceProfile   determines for which device profile configs will be returned
 @param error           error if operation fails
 
 @return list of KTKBeacon/KTKEddystone/KTKCloudBeacon objects
 */
- (NSArray *)configsPaged:(KTKPagingConfigs *)paging
           forDevicesType:(KTKDeviceType)deviceType
               andProfile:(KTKDeviceProfile)deviceProfile
                withError:(NSError **)error;

/**
 Returns list of beacons that requires configuration.
 
 @warning   Don't use it - DEPRECATED
 @see       configsForDevices:withError:
 
 @param error error if operation fails
 
 @return list of KTKBeacon objects
 */
- (NSArray *)getBeaconsToConfigureWithError:(NSError **)error __deprecated_msg("Use - (NSArray *)configsForDevices:(KTKDeviceType)deviceType withError:(NSError **)error");

/**
 Returns config for device with specified unique ID.
 
 @param uniqueID    device unique ID
 @param error       error if operation fails
 
 @return returns config for device - KTKBeacon or KTKCloudBeacon or nil
 */
- (id)configForDeviceByUniqueID:(NSString *)uniqueID withError:(NSError **)error;

/**
 Creates config for specified KTKBeacon(iBeacon)
 
 @param config  configuration of beacon that we want to apply
 @param error   error if operation fails
 
 @return true if config was created
 */
- (BOOL)configCreateForBeacon:(KTKBeacon *)config withError:(NSError **)error;

/**
 Creates config for specified KTKEddystone(Eddystone)
 
 @param config  configuration of Eddystone that we want to apply
 @param error   error if operation fails
 
 @return true if config was created
 */
- (BOOL)configCreateForEddystone:(KTKEddystone *)config withError:(NSError **)error;

/**
 Creates config for specified KTKCloudBeacon
 
 @param config  configuration of beacon that we want to apply
 @param error   error if operation fails
 
 @return true if config was created
 */
- (BOOL)configCreateForCloudBeacon:(KTKCloudBeacon *)config withError:(NSError **)error;

/**
 Creates config for specified beacon
 
 @warning   Don't use it - DEPRECATED
 @see       configCreateForBeacon:withError:
 
 @param config  configuration of beacon that we want to apply
 @param error   error if operation fails
 
 @return true if configuration was created
 */
- (BOOL)createBeaconConfig:(KTKBeacon *)config withError:(NSError **)error __deprecated_msg("Use - (BOOL)configCreateForBeacon:(KTKBeacon *)config withError:(NSError **)error");


#pragma mark - Firmware


/**
 Returns information about latest beacons firmware update for a list of specified beacons.
 
 @warning   Don't use it - DEPRECATED
 @see       firmwaresLatestForBeaconsUniqueIds:withError:
 
 @param beacons set of KTKBeaconDevice objects
 @param error error if operation fails
 
 @return dictionary of KTKFirmware objects indexed by KTKBeaconDevice objects
 */
- (NSDictionary *)getLatestFirmwareForBeacons:(NSSet *)beacons error:(NSError **)error __deprecated_msg("Use - (NSDictionary *)firmwaresForBeaconsUniqueIds:(NSArray *)uniqueIds withError:(NSError **)error");

/**
 Returns information about beacons latest firmwares(updates) for a list of specified beacons unique IDs.
 
 @param uniqueIds   list(NSString objects) of beacons unique IDs
 @param error       error if operation fails
 
 @return dictionary of KTKFirmware objects indexed by unique IDs of beacons
 */
- (NSDictionary *)firmwaresLatestForBeaconsUniqueIds:(NSArray *)uniqueIds withError:(NSError **)error;

/**
 Returns firmware object specified by firmware's name
 
 @param firmwareName    firmware's name(e.g. @"2.6")
 @param error           error if operation fails
 
 @return firmware's object or nil if operation failed or improper name was provided
 */
- (KTKFirmware *)firmwareByName:(NSString *)firmwareName withError:(NSError **)error;

/**
 Returns firmware file as bytes buffer.
 
 @param firmwareVersion number of needed firmware's version
 @param error           error if operation fails
 
 @return firmware file as bytes buffer
 */
- (NSData *)firmwareDataForVersion:(NSString *)firmwareVersion withError:(NSError **)error;


#pragma mark - Profile


/**
 Returns beacons predefined profiles/configurations array(KTKBeaconProfile objects)
 
 @param error error if operation fails
 
 @return array of beacons profiles
 */
- (NSArray *)profilesWithError:(NSError **)error;

/**
 Returns beacon profile(KTKBeaconProfile) specified by its name
 
 @param profileName name of demanded profile
 @param error       error if operation fails
 
 @return beacon profile
 */
- (KTKBeaconProfile *)profileByName:(NSString *)profileName withError:(NSError **)error;


#pragma mark - Managers


/**
 Authenticates USER by email and password, returns User object/profile with his API key etc
 
 @warning   Don't use it - DEPRECATED
 @see       managerAuthenticatedByEmail:andPassword:withError:
 
 @param email       user's email
 @param password    user's password
 @param error       error if operation fails
 
 @return user object if request succeeded
 */
- (KTKUser *)getAuthenticatedUserByEmail:(NSString *)email andPassword:(NSString *)password withError:(NSError **)error __deprecated_msg("Use - (KTKManager *)managerAuthenticatedByEmail:(NSString *)email andPassword:(NSString *)password withError:(NSError **)error");

/**
 Authenticates Manager by email and password and returns Manager object with his API-Key etc.
 
 @param email       user's email
 @param password    user's password
 @param error       error if operation fails
 
 @return manager object if request succeed
 */
- (KTKManager *)managerAuthenticatedByEmail:(NSString *)email andPassword:(NSString *)password withError:(NSError **)error;

/**
 Creates manager based on KTKManager object
 
 @warning   Don't use it - DEPRECATED
 @see       managerCreate:withError:
 
 @param manager     manager who will be created
 @param error       error if operation fails
 
 @return true if manager was created successfully
 */
- (BOOL)createManager:(KTKManager *)manager withError:(NSError **)error __deprecated_msg("Use - (BOOL)managerCreate:(KTKManager *)manager withError:(NSError **)error");

/**
 Creates manager based on KTKManager object
 
 @param manager     manager who will be created
 @param error       error if operation fails
 
 @return true if manager was created successfully
 */
- (KTKManager *)managerCreate:(KTKManager *)manager withError:(NSError **)error;

/**
 Updates manager settings based on KTKManager object
 
 @warning   Don't use it - DEPRECATED
 @see       managerUpdate:withError:
 
 @param manager     manager who will be updated with current settings
 @param error       error if operation fails
 
 @return true if manager was updated successfully
 */
- (BOOL)updateManager:(KTKManager *)manager withError:(NSError **)error __deprecated_msg("Use - (BOOL)managerUpdate:(KTKManager *)manager withError:(NSError **)error");

/**
 Updates manager properties based on KTKManager object
 
 @param manager     manager who will be updated with current settings
 @param error       error if operation fails
 
 @return true if manager was updated successfully
 */
- (BOOL)managerUpdate:(KTKManager *)manager withError:(NSError **)error;

/**
 Deletes manager based on manager's UUID
 
 @warning   Don't use it - DEPRECATED
 @see       managerDeleteByUUID:withError:
 
 @param UUID        manager's UUID who will be deleted
 @param error       error if operation fails
 
 @return true if manager was deleted successfully
 */
- (BOOL)deleteManagerWithUUID:(NSString *)UUID withError:(NSError **)error __deprecated_msg("Use - (BOOL)managerDeleteByUUID:(NSString *)managerUUID withError:(NSError **)error");

/**
 Deletes manager by his/her UUID
 
 @param managerUUID manager's UUID who will be deleted
 @param error       error if operation fails
 
 @return true if manager was deleted successfully
 */
- (BOOL)managerDeleteByUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Deletes manager based on KTKManager object
 
 @warning   Don't use it - DEPRECATED
 @see       managerDelete:withError:
 
 @param manager     manager who will be deleted
 @param error       error if operation fails
 
 @return true if manager was deleted successfully
 */
- (BOOL)deleteManager:(KTKManager *)manager withError:(NSError **)error __deprecated_msg("Use - (BOOL)managerDelete:(KTKManager *)manager withError:(NSError **)error");

/**
 Deletes manager based on KTKManager object
 
 @param manager manager who will be deleted
 @param error   error if operation fails
 
 @return true if manager was deleted successfully
 */
- (BOOL)managerDelete:(KTKManager *)manager withError:(NSError **)error;

/**
 Assigns managers to supervisor(manager) with specified UUID
 
 @warning   Don't use it - DEPRECATED
 @see       managersAssign:toSupervisorWithUUID:withError:
 
 @param managers    array of managers(KTKManager) who should be assigned
 @param UUID        supervisor's UUID to whom managers should be assigned
 @param error       error if operation fails
 
 @return true if managers were assigned successfully
 */
- (BOOL)assignManagers:(NSArray *)managers toSupervisorWithUUID:(NSString *)UUID withError:(NSError **)error __deprecated_msg("Use - (BOOL)managersAssign:(NSArray *)managers toSupervisorWithUUID:(NSString *)supervisorUUID withError:(NSError **)error");

/**
 Assigns managers to supervisor(manager) with specified UUID
 
 @param managers        array of managers(KTKManager objects) who should be assigned
 @param supervisorUUID  supervisor's UUID to whom managers should be assigned
 @param error           error if operation fails
 
 @return true if managers were assigned successfully
 */
- (BOOL)managersAssign:(NSArray *)managers toSupervisorWithUUID:(NSString *)supervisorUUID withError:(NSError **)error;

/**
 Returns list of managers
 
 @warning   Don't use it - DEPRECATED
 @see       managersAssign:toSupervisorWithUUID:withError:
 
 @param error error if operation fails
 
 @return array which is list of managers
 */
- (NSArray *)getManagersWithError:(NSError **)error __deprecated_msg("Use - (BOOL)managersAssign:(NSArray *)managers toSupervisorWithUUID:(NSString *)supervisorUUID withError:(NSError **)error");

/**
 Returns list of managers(KTKManager objects)
 
 @param error error if operation fails
 
 @return list of managers
 */
- (NSArray *)managersWithError:(NSError **)error;

/**
 Returns manager with specified UUID
 
 @warning   Don't use it - DEPRECATED
 @see       - (KTKManager *)managerByUUID:(NSString *)managerUUID withError:(NSError **)error
 
 @param UUID    manager's UUID
 @param error   error if operation fails
 
 @return manager with specified UUID
 */
- (KTKManager *)getManagerWithUUID:(NSString *)UUID withError:(NSError **)error __deprecated_msg("Use - (KTKManager *)managerByUUID:(NSString *)managerUUID withError:(NSError **)error");

/**
 Returns manager(KTKManager) with specified UUID
 
 @param managerUUID manager's UUID
 @param error       error if operation fails
 
 @return manager if there was the one that matches specified UUID
 */
- (KTKManager *)managerByUUID:(NSString *)managerUUID withError:(NSError **)error;

/**
 Returns list of subordinates
 
 @warning   Don't use it - DEPRECATED
 @see       managerSubordinatesByUUID:withError:
 
 @param UUID manager's UUID
 @param error error if operation fails
 
 @return array which is list of manager's subordinates
 */
- (NSArray *)getSubordinatesForManagerByUUID:(NSUUID *)UUID withError:(NSError **)error __deprecated_msg("Use - (NSArray *)managerSubordinatesByUUID:(NSUUID *)managerUUID withError:(NSError **)error");

/**
 Returns list of manager's subordinates(KTKSubordinate objects)
 
 @param managerUUID manager's UUID
 @param error       error if operation fails
 
 @return array which is list of manager's subordinates
 */
- (NSArray *)managerSubordinatesByUUID:(NSString *)managerUUID withError:(NSError **)error;


#pragma mark - Venues


/**
 Returns venue for specified UUID
 
 @param venueUUID   venue's UUID that we want to get
 @param error       error if operation fails
 
 @return venue or nil if venue doesn't exist
 */
- (KTKVenue *)venueByUUID:(NSString *)venueUUID withError:(NSError **)error;

/**
 Returns venue's image data for specified venue's UUID
 
 @param venueUUID   venue's UUID for which we want to get image/cover
 @param error       error if operation fails
 
 @return image data or nil
 */
- (NSData *)venueImageDataByUUID:(NSString *)venueUUID withError:(NSError **)error;

/**
 Returns array of venues(KTKVenue objects) for currently logged in manager + public ones
 Can return only public ones if no one is logged in and public APIKey is provided
 
 @param error error if operation fails
 
 @return array of venues
 */
- (NSArray *)venuesWithError:(NSError **)error;

/**
 Returns array of venues(KTKVenue objects) for manager(whose UUID was passed) and venues' type(optional - default private)
 
 @param managerUUID manager's UUID
 @param venueType   venue's type
 @param error       error if operation fails
 
 @return array of venues that met selection criteria
 */
- (NSArray *)venuesByManagerUUID:(NSString *)managerUUID andType:(KTKVenueType)venueType withError:(NSError **)error;

/**
 Returns array of venues which are the properties of manager whose Api-Key is provided
 
 @param paging  object which determines set of data that should be returned
 @param error   error if operation fails
 
 @return array of venues(KTKVenue objects)
 */
- (NSArray *)venuesPaged:(KTKPagingVenues *)paging withError:(NSError **)error;

/**
 Returns array of venues(KTKVenue objects) for manager(whose UUID was passed) and venues' type(optional - default private)

 @param paging      object which determines set of data that should be returned
 @param managerUUID manager's UUID
 @param venueType   venue's type
 @param error       error if operation fails
 
 @return array of venues that met selection criteria
 */
- (NSArray *)venuesPaged:(KTKPagingVenues *)paging byManagerUUID:(NSString *)managerUUID andType:(KTKVenueType)venueType withError:(NSError **)error;

/**
 Returns BOOL value which tells if CREATE venue operation succeeded
 
 @param name        name for venue
 @param description description for venue
 @param imageData   image as NSData - OPTIONAL(can be nil)
 @param error       error if operation fails
 
 @return YES if venue was successfully created or NO if not
 */
- (BOOL)venueCreateWithName:(NSString *)name description:(NSString *)description andImageData:(NSData *)imageData withError:(NSError **)error;

/**
 Returns BOOL value which tells if DELETED venue operation succeeded
 
 @param venueUUID   vanue's UUID
 @param error       error if operation fails
 
 @return YES if venue was successfully DELETED or NO if not
 */
- (BOOL)venueDeleteByUUID:(NSString *)venueUUID withError:(NSError **)error;

/**
 Returns BOOL value which tells if UPDATE venue operation succeeded
 ALL PARAMS are optional - still there must be at least one none nil value to make an update
 
 @param venueUUID   vanue's UUID
 @param name        name for venue
 @param description description for venue
 @param imageData   image as NSData - OPTIONAL(can be nil)
 @param error       error if operation fails
 
 @return YES if venue was successfully UPDATED or NO if not
 */
- (BOOL)venueUpdateByUUID:(NSString *)venueUUID name:(NSString *)name description:(NSString *)description andImageData:(NSData *)imageData withError:(NSError **)error;

/**
 Returns BOOL value which tells if ADDING venue to VERIFICATION operation succeeded
 
 @param venueUUID   vanue's UUID
 @param error       error if operation fails
 
 @return YES if venue was successfully ADDED to VERIFICATION or NO if not
 */
- (BOOL)venueAddToVerificationByUUID:(NSString *)venueUUID withError:(NSError **)error;


#pragma mark - Public


/**
 Returns array of public venues(KTKPublicVenue objects) for currently logged in manager
 
 @param error error if operation fails
 
 @return array of manager's public venues
 */
- (NSArray *)publicVenuesWithError:(NSError **)error;

/**
 Returns public venue(KTKPublicVenue) for currently logged in manager
 
 @param venueUUID   public venue's UUID
 @param error       error if operation fails
 
 @return public venue or nil(if doesn't exist)
 */
- (KTKPublicVenue *)publicVenueByUUID:(NSString *)venueUUID withError:(NSError **)error;

/**
 Returns public beacon(KTKPublicBeacon) by UUID for currently logged in manager
 
 @param beaconUUID  public beacon's UUID
 @param error       error if operation fails
 
 @return public beacon or nil(if doesn't exist)
 */
- (KTKPublicBeacon *)publicBeaconByUUID:(NSString *)beaconUUID withError:(NSError **)error;

/**
 Returns public action(KTKPublicAction) by UUID for currently logged in manager
 
 @param actionUUID  public action's UUID
 @param error       error if operation fails
 
 @return public action or nil(if doesn't exist)
 */
- (KTKPublicAction *)publicActionByUUID:(NSString *)actionUUID withError:(NSError **)error;

/**
 Returns BOOL value which tells if UPDATE venue operation succeeded
 
 @param venueUUID   vanue's UUID
 @param status      venue's status - VERIFIED, REJECTED (may be changed by user with verifier role), PUBLISHED, VERIFIED (may be changed by manager)
 @param message     some message - OPTIONAL
 @param error       error if operation fails
 
 @return YES if venue was successfully UPDATED or NO if not
 */
- (BOOL)publicVenueUpdateByUUID:(NSString *)venueUUID status:(NSString *)status andMessage:(NSString *)message withError:(NSError **)error;

/**
 Returns BOOL value which tells if DELETE venue operation succeeded
 
 @param venueUUID   vanue's UUID
 @param error       error if operation fails
 
 @return YES if venue was successfully DELETED or NO if not
 */
- (BOOL)publicVenueDeleteByUUID:(NSString *)venueUUID withError:(NSError **)error;


#pragma mark - Requests


/**
 Returns properly signed request(without API key attached/in header - atm for authentication) to 
 specified endpoint's category and it's subcategory. You can use this method to create custom requests.
 
 @param     category    endpoint's category like @"manager"
 @param     subcategory endpoint's subcategory(which is related to its category) like @"authenticate"
 
 @return    return      signed request
 */
- (NSMutableURLRequest *)createRequestWithoutApiKeyToEndpointCategory:(NSString *)category
                                                       andSubcategory:(NSString *)subcategory;

/**
 Returns properly signed request to specified endpoint's category and it's subcategory. You can use this method to create custom requests.
 
 @param     category    endpoint's category like @"action"
 @param     subcategory endpoint's subcategory(which is related to its category) like @":id/content"
 
 @return    return      signed request
 */
- (NSMutableURLRequest *)createRequestToEndpointCategory:(NSString *)category andSubcategory:(NSString *)subcategory;

/**
 Returns properly signed request to specified endpoint. You can use this method to create custom requests.
 
 @param endpoint endpoint
 
 @return return signed request
 */
- (NSMutableURLRequest *)createRequestToEndpoint:(NSString *)endpoint;

/**
 Sends request to API. You can use this methods to execute custom requests.
 
 @param request request to be sent
 @param error error if opertaion fails
 
 @return data returned by API
 */
- (NSData *)sendRequest:(NSURLRequest *)request error:(NSError **)error;

@end
