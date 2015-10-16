//
//  KTKPagingVenues.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 2/2/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import "KTKPaging.h"


/**
 Venues order by possible values
 */
typedef NS_ENUM(NSUInteger, KTKVenuesOrderBy)
{
    /**
     Venues oredered by Created date - default
     */
    KTKVenuesOrderByCreated,
    
    /**
     Venues oredered by Updated date
     */
    KTKVenuesOrderByUpdated,
    
    /**
     Venues oredered by Name
     */
    KTKVenuesOrderByName,
    
    /**
     Venues oredered by Description
     */
    KTKVenuesOrderByDescription
};


/**
 KTKPagingVenues is class representing Paging for Venues.
 */
@interface KTKPagingVenues : KTKPaging

/**
 Venues paged request results order by field descriptor
 */
@property (nonatomic) KTKVenuesOrderBy orderBy;

/**
 Initializes new KTKPagingVenues object with specified index start, max results and order by descriptor
 
 @param indexStart  paged venues start index
 @param maxResults  paged venues max results
 @param orderBy     paged venues order by
 
 @return KTKPagingVenues object
 */
- (id)initWithIndexStart:(NSUInteger)indexStart maxResults:(NSUInteger)maxResults andOrderBy:(KTKVenuesOrderBy)orderBy;

/**
 Returns order by as string that is used in requests
 
 @return order by parameter as a string
 */
- (NSString *)orderByAsString;

@end
