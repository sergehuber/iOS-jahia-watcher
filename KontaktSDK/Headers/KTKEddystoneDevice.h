//
//  KTKEddystoneDevice.h
//  Eddystone
//
//  Created by Marek Serafin on 07/04/15.
//  Copyright (c) 2015 Kontakt.io. All rights reserved.
//

#import "KTKBeaconDevice.h"

#import "KTKEddystoneUID.h"
#import "KTKEddystoneURL.h"
#import "KTKEddystoneTLM.h"


/**
 Possible types of KTKEddystone proximity
 */
typedef NS_ENUM(NSInteger, KTKEddystoneDeviceProximity) {
    /**
     Proxmimity unknown
     */
    KTKEddystoneDeviceProximityUnknown,
    /**
     Proxmimity immediate
     */
    KTKEddystoneDeviceProximityImmediate,
    /**
     Proxmimity near
     */
    KTKEddystoneDeviceProximityNear,
    /**
     Proxmimity far
     */
    KTKEddystoneDeviceProximityFar
};

/**
 Represents beacon device with Eddystone beacon format
 */
@interface KTKEddystoneDevice : KTKBeaconDevice

/**
 Eddystone UID frame data
 */
@property (nonatomic, strong, readonly) KTKEddystoneUID *eddystoneUID;
/**
 Eddystone URL frame data
 */
@property (nonatomic, strong, readonly) KTKEddystoneURL *eddystoneURL;
/**
 Eddystone TLM frame data
 */
@property (nonatomic, strong, readonly) KTKEddystoneTLM *eddystoneTLM;

/**
 Eddystone TX power
 */
@property (nonatomic, assign, readonly) NSInteger txPower;
/**
 Eddystone proximity
 */
@property (nonatomic, assign, readonly) KTKEddystoneDeviceProximity proximity;
/**
 Eddystone calculated accuracy
 */
@property (nonatomic, assign, readonly) double accuracy;

/**
 Flage which tells if all 3 data frames(UID,URL,TLM) were received for this Eddystone
 */
@property (nonatomic, assign, readonly, getter=isComplete) BOOL complete;


@end
