//
//  KTKEddystoneRegion.h
//  Eddystone
//
//  Created by Marek Serafin on 29/04/15.
//  Copyright (c) 2015 Kontakt.io. All rights reserved.
//

@import Foundation;

@class KTKEddystoneUID;

/**
 Represents Eddystone region - it has similiar functionality as KTKRegion for KTKBeaconDevice
 */
@interface KTKEddystoneRegion : NSObject

/**
 Eddystone UID
 */
@property (nonatomic, strong, readwrite) KTKEddystoneUID *eddystoneUID;

/**
 Returns Eddystone region
 
 @param uid Eddystone UID(namespace ID + instance ID)
 
 @return Eddystone region
 */
+ (KTKEddystoneRegion*)regionWithUID:(KTKEddystoneUID*)uid;

@end
