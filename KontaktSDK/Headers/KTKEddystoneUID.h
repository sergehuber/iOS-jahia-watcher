//
//  KTKEddystoneID.h
//  Eddystone
//
//  Created by Marek Serafin on 07/04/15.
//  Copyright (c) 2015 Kontakt.io. All rights reserved.
//

@import Foundation;
#import "KTKEddystoneFrame.h"

#pragma mark - Types
/**
 Type for Eddystone namespace ID
 */
typedef NSData KTKEddystoneUIDNamespaceID;
/**
 Type for Eddystone instance ID
 */
typedef NSData KTKEddystoneUIDInstanceID;

#pragma mark - NSData (KTKEddystoneUID)

/**
 NSData category that supports conversion of IDs to NSString
 */
@interface NSData (KTKEddystoneUID)

/**
 Returns any Eddystone ID converted to string
 */
- (NSString*)IDString;

@end


#pragma mark - KTKEddystoneFrameUID
/**
 Represents KTKEddystone UID(with namespaceID and instanceID) data frame
 */
@interface KTKEddystoneUID : NSObject <KTKEddystoneFrame>

/**
 Eddystone namespace ID
 */
@property (nonatomic, strong, readwrite) KTKEddystoneUIDNamespaceID *namespaceID;
/**
 Eddystone instance ID
 */
@property (nonatomic, strong, readwrite) KTKEddystoneUIDInstanceID *instanceID;

/**
 Returns Eddystone UID from given namespace ID and instance ID
 
 @param namespaceID Eddystone namespace ID
 @param instanceID  Eddystone instance ID
 
 @return Eddystone UID
 */
+ (KTKEddystoneUID*)UIDWithNamespaceIDString:(NSString*)namespaceID
                            instanceIDString:(NSString*)instanceID;

@end
