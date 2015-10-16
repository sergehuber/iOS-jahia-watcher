//
//  KTKBeaconDevice.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 20/12/13.
//  Copyright (c) 2013 kontakt. All rights reserved.
//

#import "KTKBluetoothDevice.h"


/**
 Possible states of firmware update process.
 */
typedef NS_ENUM(int, KTKBeaconDeviceFirmwareUpdateState) {
    /**
     Beacon is being prepared for firmware update.
     */
    KTKBeaconDeviceFirmwareUpdateStatePreparing,
    
    /**
     Firmware is being uploaded to beacon.
     */
    KTKBeaconDeviceFirmwareUpdateStateUploading,
};


@class KTKBluetoothManager, KTKFirmware;

/**
 Represents Kontakt beacon device.
 */
@interface KTKBeaconDevice : KTKBluetoothDevice

#pragma mark - properties

/**
 Logic value indicating if beacon is in DFU.
 */
@property (nonatomic) BOOL isInDfuMode;

/**
 Beacon's RSSI.
 */
@property (nonatomic) NSNumber *RSSI;

/**
 Logic value indicating if beacon is locked.
 */
@property (nonatomic, readonly) BOOL locked;

/**
 Unique identifier of a beacon.
 */
@property (nonatomic, readonly) NSString *uniqueID;

/**
 Percentage value of battery state.
 */
@property (nonatomic, readonly) NSUInteger batteryLevel;

/**
 Firmware version number
 */
@property (nonatomic, readonly) NSDecimalNumber *firmwareVersion;

/**
 Timestap information when beacon was 'ranged' for the last time
 */
@property (nonatomic, assign, readonly) double updatedAt;


#pragma mark - public methods

/**
 Connects to device with specified password
 
 @param password    beacon's security password
 @param error       error if operation fails
 
 @return YES if connection operation suceeded - NO if not
 */
- (BOOL)connectWithPassword:(NSString *)password andError:(NSError **)error;

/**
 Can be used for pre-checking if password format is valid
 
 @param password beacon's security password
 
 @return YES if password format is valid - NO if not
 */
- (BOOL)isPasswordFormatValid:(NSString *)password;

/**
 Disconnects from device.
 */
- (void)disconnect;

/**
 Authorizes connection to the beacon using password set by setPassword: method.
 
 @warning   Don't use it - DEPRECATED
 @see       connectWithPassword:andError:
 
 @return error if opertion fails
 */
- (NSError *)authorize __deprecated_msg("Use - (BOOL)connectWithPassword:(NSString *)password andError:(NSError **)error");

/**
 Sets password used to authorize connection to the beacon.
 
 @warning   Don't use it - DEPRECATED
 @see       connectWithPassword:andError:
 
 @param password password for the beacon
 @return error if operation fails
 */
- (NSError *)setPassword:(NSString *)password __deprecated_msg("Use - (BOOL)connectWithPassword:(NSString *)password andError:(NSError **)error");

/**
 Returns characteristic descriptor for a specific characteristic kind.
 
 @param type type of characteristic
 @return characteristic descriptor
 */
- (KTKCharacteristicDescriptor *)characteristicDescriptorWithType:(NSString *)type;

/**
 Returns service descriptor for a specific service kind.
 
 @param type type of service
 @return service descriptor
 */
- (KTKServiceDescriptor *)serviceDescriptorWithType:(NSString *)type;

/**
 Updates beacon firmware. This methods is blocking and waits for operation to finish.
 
 @param firmware firmware
 @param masterPassword password required to update beacons firmware, this passwoed is different than regular password used to connect to the beacon
 @param progressHandler block of code that is invoked to give a feedback about update progress, if state parameter is KTKBeaconDeviceFirmwareUpdateStateUploading then progress parameters contains value between 0 nad 1 that indicates progress of firmware upload process
 
 @return error if operation fails
 */
- (NSError *)updateFirmware:(KTKFirmware *)firmware
        usingMasterPassword:(NSString *)masterPassword
            progressHandler:(void (^)(KTKBeaconDeviceFirmwareUpdateState state, int progress))progressHandler;

/**
 Updates beacon firmware if beacon is in DFU mode. This methods is non-blocking.
 
 @param firmware        firmware object
 @param progressHandler block of code that is invoked to give a feedback about update progress,
 if state parameter is KTKBeaconDeviceFirmwareUpdateStateUploading then progress parameters
 contains value between 0 nad 1 that indicates progress of firmare upload process
 
 @return error if operation fails
 */
- (NSError *)updateFirmwareForDfu:(KTKFirmware *)firmware
              withProgressHandler:(void (^)(KTKBeaconDeviceFirmwareUpdateState, int))progressHandler;

@end
