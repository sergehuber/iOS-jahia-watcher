//
//  KTKBeacon.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 14/03/14.
//  Copyright (c) 2014 kontakt.io. All rights reserved.
//

#import "KTKDataTransferObject.h"

#import "KTKDevice.h"


@protocol KTKVenue;

/**
 KTKBeacon is a protocol that should be implemented by any object that represents a beacon or its config.
 */
@protocol KTKBeacon <KTKDataTransferObject>

/**
 Alias of the beacon.
 */
@property (strong, nonatomic, readonly) NSString *alias;

/**
 Firmwave revision number. By default this property is nil but you can assign new value to change it.
 */
@property (strong, nonatomic, readonly) NSString *firmware;

/**
 Broadcasting interval.
 */
@property (strong, nonatomic, readonly) NSNumber *interval;

/**
 Major number of the beacon.
 */
@property (strong, nonatomic, readonly) NSNumber *major;

/**
 Minor number of the beacon.
 */
@property (strong, nonatomic, readonly) NSNumber *minor;

/**
 Custom name of the beacon.
 */
@property (strong, nonatomic, readonly) NSString *name;

/**
 Unique identifier of the beacon.
 */
@property (strong, nonatomic, readonly) NSString *uniqueID;

/**
 Password for the beacon. By default this property is nil but you can assign new value to change it.
 */
@property (strong, nonatomic, readonly) NSString *password;

/**
 Transmission power of the beacon.
 */
@property (strong, nonatomic, readonly) NSNumber *power;

/**
 Priximity UUID of the beacon.
 */
@property (strong, nonatomic, readonly) NSString *proximity;

/**
 Beacon's manager(owner) UUID
 */
@property (strong, nonatomic, readonly) NSString *managerUUID;

@optional

/**
 Actions assigned to the beacon.
 */
@property (strong, nonatomic, readonly) NSSet *actions;

/**
 Venue that the beacon is assigned to.
 */
@property (strong, nonatomic, readwrite) id<KTKVenue> venue;

/**
 Beacon's profile type - iBeacon or Eddystone
 */
@property (nonatomic, readonly) KTKDeviceProfile profile;

@end

/**
 KTKBeacon is a class representing a beacon or its config.
 */
@interface KTKBeacon : KTKDataTransferObject <KTKBeacon>

#pragma mark - properties

@property (strong, nonatomic, readwrite) NSString *alias;
@property (strong, nonatomic, readwrite) NSString *firmware;
@property (strong, nonatomic, readwrite) NSNumber *interval;
@property (strong, nonatomic, readwrite) NSNumber *major;
@property (strong, nonatomic, readwrite) NSNumber *minor;
@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSString *uniqueID;
@property (strong, nonatomic, readwrite) NSString *password;
@property (strong, nonatomic, readwrite) NSNumber *power;
@property (strong, nonatomic, readwrite) NSString *proximity;
@property (strong, nonatomic, readwrite) NSString *managerUUID;
@property (strong, nonatomic, readwrite) NSSet *actions;
@property (strong, nonatomic, readwrite) id<KTKVenue> venue;
@property (nonatomic, readwrite) KTKDeviceProfile profile;

@end
