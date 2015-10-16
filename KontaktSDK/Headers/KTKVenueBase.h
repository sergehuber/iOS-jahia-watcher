//
//  KTKVenueBase.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 12/5/14.
//  Copyright (c) 2014 kontakt.io. All rights reserved.
//

#import "KTKDataTransferObject.h"


/**
 Venue Type possible values
 */
typedef NS_ENUM(NSUInteger, KTKVenueType)
{
    /**
     Venue type Private - default
     */
    KTKVenueTypePrivate,
    
    /**
     Venue type Public
     */
    KTKVenueTypePublic
};

/**
 KTKVenueBase is a protocol that should be implemented by any class that represents venue.
 */
@protocol KTKVenueBase <KTKDataTransferObject>

/**
 Venue's name.
 */
@property (strong, nonatomic, readonly) NSString *name;

/**
 Venue's description.
 */
@property (strong, nonatomic, readonly) NSString *desc;

/**
 Venue's cover/image URL.
 */
@property (strong, nonatomic, readonly) NSString *imageURL;

/**
 Type of the venue's cover.
 */
@property (strong, nonatomic, readonly) NSString *coverType;

/**
 Count of beacons assigned to the venue.
 */
@property (nonatomic, readonly) NSUInteger beaconsCount;

/**
 Beacons assigned to the venue.
 */
@property (strong, nonatomic, readonly) NSSet *beacons;

@end


/**
 KTKVenueBase is a class representing base/basic properties of venue.
 */
@interface KTKVenueBase : KTKDataTransferObject <KTKVenueBase>

#pragma mark - properties

@property (strong, nonatomic, readwrite) NSString *name;
@property (strong, nonatomic, readwrite) NSString *desc;
@property (strong, nonatomic, readwrite) NSString *imageURL;
@property (strong, nonatomic, readwrite) NSString *coverType;
@property (nonatomic, readwrite)         NSUInteger beaconsCount;
@property (strong, nonatomic, readwrite) NSSet *beacons;

/**
 Returns Venue Type as string - for requests etc.
 
 @param venueType venue's type
 
 @return string that is adequate to given type - Private(default)
 */
+ (NSString *)venueTypeAsString:(KTKVenueType)venueType;

@end
