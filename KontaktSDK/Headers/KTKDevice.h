//
//  KTKDevice.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 2/20/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import "KTKDataTransferObject.h"


/**
 Devices types enumerator
 */
typedef NS_ENUM(NSUInteger, KTKDeviceType)
{
    /**
     Device's type iBeacon
     */
    KTKDeviceTypeBeacon = 0,
    
    /**
     Device's type Cloud Beacon
     */
    KTKDeviceTypeCloudBeacon = 1
};

/**
 Devices possible profiles
 */
typedef NS_ENUM(NSUInteger, KTKDeviceProfile)
{
    /**
     Device's profile iBeacon
     */
    KTKDeviceProfileBeacon = 0,
    
    /**
     Device's profile Eddystopne
     */
    KTKDeviceProfileEddystone = 1
};

/**
 KTKDevice is a class representing device
 */
@interface KTKDevice : KTKDataTransferObject

/**
 Returns device type as string that is used in requests

 @param deviceType device's type
 
 @return device type as a string
 */
+ (NSString *)deviceTypeStringValue:(KTKDeviceType)deviceType;

/**
 Returns device type as enum that is used in methods that are related to devices types etc.
 
 @param deviceTypeString device's type as a string
 
 @return device type as enum
 */
+ (KTKDeviceType)deviceTypeFromString:(NSString *)deviceTypeString;

/**
 Returns device profile as string that is used in API requests
 
 @param deviceProfile device's profile - for beacons
 
 @return device profile as a string
 */
+ (NSString *)deviceProfileStringValue:(KTKDeviceProfile)deviceProfile;

/**
 Returns device profile as enum that is used in methods that check devices profiles etc.
 
 @param deviceProfileString device's profile as a string - eg. from API response
 
 @return device profile as enum
 */
+ (KTKDeviceProfile)deviceProfileWithString:(NSString *)deviceProfileString;

@end
