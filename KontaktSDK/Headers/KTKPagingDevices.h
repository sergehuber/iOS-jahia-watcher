//
//  KTKPagingDevices.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 2/3/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import "KTKPaging.h"


/**
 Devices order by possible types/values
 */
typedef NS_ENUM(NSUInteger, KTKDevicesOrderBy)
{    
    /**
     Devices ordered by Created date - default
     */
    KTKDevicesOrderByCreated,
    
    /**
     Devices ordered by Updated date
     */
    KTKDevicesOrderByUpdated,
    
    /**
     Devices ordered by Name
     */
    KTKDevicesOrderByName,
    
    /**
     Devices ordered by ID
     */
    KTKDevicesOrderById,
    
    /**
     Devices ordered by Unique ID
     */
    KTKDevicesOrderByUniqueId,
    
    /**
     Devices ordered by Proximity
     */
    KTKDevicesOrderByProximity,
    
    /**
     Devices ordered by Major
     */
    KTKDevicesOrderByMajor,
    
    /**
     Devices ordered by Minor
     */
    KTKDevicesOrderByMinor,
    
    /**
     Devices ordered by TX Power
     */
    KTKDevicesOrderByTxPower
};

/**
 KTKPagingDevices is class representing Paging for Devices.
 */
@interface KTKPagingDevices : KTKPaging

/**
 Devices paged request results order by field descriptor
 */
@property (nonatomic) KTKDevicesOrderBy orderBy;

/**
 Initializes new KTKPagingDevices object with specified index start, max results and order by descriptor
 
 @param indexStart  paged devices start index
 @param maxResults  paged devices max results
 @param orderBy     paged devices order by
 
 @return KTKPagingDevices object
 */
- (id)initWithIndexStart:(NSUInteger)indexStart maxResults:(NSUInteger)maxResults andOrderBy:(KTKDevicesOrderBy)orderBy;

/**
 Returns order by as string that is used in requests
 
 @return order by parameter as a string
 */
- (NSString *)orderByAsString;

@end
