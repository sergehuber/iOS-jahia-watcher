//
//  KTKEddystone.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 7/16/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import "KTKBeacon.h"


@class KTKVenue;


/**
 KTKEddystone is a class representing API model Eddystone(ES) beacon format OR its config
 */
@interface KTKEddystone : KTKBeacon

/**
 Eddystone namespace ID - value in HEX. 
 You can treat it similiary as proximity(UUID) in KTKBeaconDevice(iBeacon)
 */
@property (nonatomic) NSString *namespaceIdHex;
/**
 Eddystone instance ID - value in HEX.
 You can treat it more or less, similiary as major in KTKBeaconDevice(iBeacon)
 */
@property (nonatomic) NSString *instanceIdHex;
/**
 Eddystone URL - value in HEX.
 It's url that you want to be brodcatested by Eddystone
 */
@property (nonatomic) NSString *urlHex;

@end
