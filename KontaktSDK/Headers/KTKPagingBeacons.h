//
//  KTKPagingBeacons.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 1/27/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "KTKPaging.h"


/**
 Beacons order by possible values
 */
typedef NS_ENUM(NSUInteger, KTKBeaconsOrderBy)
{
    /**
     Beacons ordered by Created date - default
     */
    KTKBeaconsOrderByCreated,
    
    /**
     Beacons ordered by Updated date
     */
    KTKBeaconsOrderByUpdated,
    
    /**
     Beacons ordered by Name
     */
    KTKBeaconsOrderByName,
    
    /**
     Beacons ordered by Unique ID
     */
    KTKBeaconsOrderByUniqueId,
    
    /**
     Beacons ordered by Alias
     */
    KTKBeaconsOrderByAlias,
    
    /**
     Beacons ordered by Proximity
     */
    KTKBeaconsOrderByProximity,
    
    /**
     Beacons ordered by Major
     */
    KTKBeaconsOrderByMajor,
    
    /**
     Beacons ordered by Minor
     */
    KTKBeaconsOrderByMinor,
    
    /**
     Beacons ordered by TX Power
     */
    KTKBeaconsOrderByTxPower
};


/**
 KTKPagingBeacons is class representing Paging for Beacons.
 */
@interface KTKPagingBeacons : KTKPaging

/**
 Beacons paged request results order by field descriptor
 */
@property (nonatomic) KTKBeaconsOrderBy orderBy;

/**
 Initializes new KTKPagingBeacons object with specified index start, max results and order by descriptor
 
 @param indexStart  paged beacons start index
 @param maxResults  paged beacons max results
 @param orderBy     paged beacons order by
 
 @return KTKPagingBeacons object
 */
- (id)initWithIndexStart:(NSUInteger)indexStart maxResults:(NSUInteger)maxResults andOrderBy:(KTKBeaconsOrderBy)orderBy;

/**
 Returns order by as string that is used in requests
 
 @return order by parameter as a string
 */
- (NSString *)orderByAsString;

@end
