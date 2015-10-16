//
//  KTKCloudBeacon.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 1/21/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KTKBeacon.h"

/**
 KTKCloudBeacon is a protocol that should be implemented by any object that represents Cloud Beacon or its config.
 */
@protocol KTKCloudBeacon <KTKBeacon>

/**
 Default SSID(service set identifier/"network name") name.
 */
@property (strong, nonatomic, readonly) NSString *defaultSSIDName;

/**
 Default SSID(service set identifier/"network name") key.
 At this moment only used for Cloud Beacon config purpose.
 */
@property (strong, nonatomic, readonly) NSString *defaultSSIDKey;

/**
 Default SSID(service set identifier/"network name") authentication type.
 */
@property (strong, nonatomic, readonly) NSString *defaultSSIDAuth;

/**
 Default SSID(service set identifier/"network name") encryption mode.
 */
@property (strong, nonatomic, readonly) NSString *defaultSSIDCrypt;

/**
 Cloud Beacon's working mode.
 */
@property (strong, nonatomic, readonly) NSString *workingMode;

/**
 Wi-Fi scanning interval.
 */
@property (nonatomic, readonly) NSUInteger wifiScanInterval;

/**
 Data sending interval.
 */
@property (nonatomic, readonly) NSUInteger dataSendInterval;

/**
 BLE scanning interval.
 */
@property (nonatomic, readonly) NSUInteger bleScanInterval;

/**
 BLE scanning duration.
 */
@property (nonatomic, readonly) NSUInteger bleScanDuration;

@end


/**
 KTKCloudBeacon is a class representing Cloud Beacon or its config.
 */
@interface KTKCloudBeacon : KTKBeacon <KTKCloudBeacon>

#pragma mark - properties

@property (strong, nonatomic, readwrite) NSString *defaultSSIDName;
@property (strong, nonatomic, readwrite) NSString *defaultSSIDKey;
@property (strong, nonatomic, readwrite) NSString *defaultSSIDAuth;
@property (strong, nonatomic, readwrite) NSString *defaultSSIDCrypt;
@property (strong, nonatomic, readwrite) NSString *workingMode;
@property (nonatomic, readwrite) NSUInteger wifiScanInterval;
@property (nonatomic, readwrite) NSUInteger dataSendInterval;
@property (nonatomic, readwrite) NSUInteger bleScanInterval;
@property (nonatomic, readwrite) NSUInteger bleScanDuration;

@end
