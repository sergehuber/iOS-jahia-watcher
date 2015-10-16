//
//  KTKBluetoothManager.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 19/12/13.
//  Copyright (c) 2013 kontakt. All rights reserved.
//

@class KTKBluetoothManager;
@class KTKEddystoneDevice;


#pragma mark - Statics

/**
 Kontakt iBeacon device profile number as string - for BLE characteristic
 */
static NSString *DeviceProfileNumberStringBeacon    = @"1";

/**
 Kontakt Eddystone device profile number as string - for BLE characteristic
 */
static NSString *DeviceProfileNumberStringEddystone = @"2";

/**
 Kontakt device firmware version number from which we can change its profile
 */
static float DeviceFirmwareVersionWithProfiles = 3.0;


#pragma mark - Protocol

/**
 Responds to bluetooth manager events. Methods are invoked on main thread.
 */
@protocol KTKBluetoothManagerDelegate <NSObject>

/**
 Bluetooth manager informs which Eddystones devices are currently in range with it's latest(refreshed) properties
 You should have it executed every second.
 
 @param bluetoothManager    bluetooth manager that calls this method
 @param devices             set of new and updated KTKBeaconDevice objects
 */
- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didChangeDevices:(NSSet *)devices;
/**
 Bluetooth manager informs which Eddystones devices are currently in range with it's latest(refreshed) properties
 You should have it executed every second.
 
 @param bluetoothManager    bluetooth manager that calls this method
 @param eddystones          set of new and updated KTKEddystone objects
 */
- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didChangeEddystones:(NSSet *)eddystones;

@optional
/**
 Informs that bluetooth manager has ranged(received UID data frame) specified Eddystone device
 
 @param bluetoothManager    bluetooth manager that calls this method
 @param eddystone           Eddystone device that was discovered
 */
- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didDiscoverEddystone:(KTKEddystoneDevice *)eddystone;
/**
 Informs that bluetooth manager has lost(out of range) specified Eddystone device
 
 @param bluetoothManager    bluetooth manager that calls this method
 @param eddystone           Eddystone device that is out of range now
 */
- (void)bluetoothManager:(KTKBluetoothManager *)bluetoothManager didLoseEddystone:(KTKEddystoneDevice *)eddystone;

@end

/**
 Allows to easily search for nearby bluetooth devices.
 */
@interface KTKBluetoothManager : NSObject

#pragma mark - properties

/**
  Responds to bluetooth manager events.
 */
@property (weak, nonatomic, readwrite) id<KTKBluetoothManagerDelegate> delegate;

#pragma mark - public methods

/**
 Return array of all discovered bluethooth devices.
 
 @return array of KTKBluetoothDevice objects
 */
- (NSArray *)devices;

/**
 Forces bluethooth manager to forget all devices and discover them again.
 */
- (void)reloadDevices;

/**
 Tells bluetooth manager to start discovering devices.
 */
- (void)startFindingDevices;

/**
 Tells bluetooth manager to stop discovering devices.
 */
- (void)stopFindingDevices;

@end
