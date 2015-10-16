//
//  KTKEddystoneFrame.h
//  Eddystone
//
//  Created by Marek Serafin on 08/04/15.
//  Copyright (c) 2015 Kontakt.io. All rights reserved.
//

@import Foundation;

/**
 Possible types of KTKEddystone data frames.
 */
typedef NS_ENUM(NSUInteger, KTKEddystoneFrameType) {
    /**
     Frame with UID data - namespaceID and instanceID 
     */
    KTKEddystoneFrameTypeUID = 0x00,
    /**
     Frame with URL data
     */
    KTKEddystoneFrameTypeURL = 0x10,
    /**
     Frame with TLM data - telemetrics
     */
    KTKEddystoneFrameTypeTLM = 0x20
};

/**
 KTKEddystoneFrame is a protocol that should be implemented by any object that represents Eddystone data frame.
 */
@protocol KTKEddystoneFrame <NSObject>

/**
 Type of KTKEddystone data frame
 */
@property (nonatomic, assign, readonly) KTKEddystoneFrameType type;

@end
