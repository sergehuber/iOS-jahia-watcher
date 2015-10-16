//
//  KTKPublicAction.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 12/8/14.
//  Copyright (c) 2014 kontakt.io. All rights reserved.
//

#import "KTKAction.h"


/**
 KTKPublicAction is a protocol that should be implemented by any object that represents a Public Action assigned to a beacon.
 */
@protocol KTKPublicAction <KTKAction>

/**
 Public action's status - VERIFICATION, VERIFIED, PUBLISHED, REJECTED.
 */
@property (strong, nonatomic, readonly) NSString *status;

/**
 Public action source UUID(manager's action UUID  which is base for this public one)
 */
@property (strong, nonatomic, readonly) NSString *sourceUUID;

@end


/**
 KTKPublicAction is a class representing a Public Action assigned to a beacon.
 */
@interface KTKPublicAction : KTKAction <KTKPublicAction>

@property (strong, nonatomic, readwrite) NSString *status;
@property (strong, nonatomic, readwrite) NSString *sourceUUID;

@end
