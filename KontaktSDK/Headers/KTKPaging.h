//
//  KTKPaging.h
//  kontakt-ios-sdk
//
//  Created by Lukasz Hlebowicz on 1/27/15.
//  Copyright (c) 2015 kontakt.io. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const KTKOrderAscending;
extern NSString * const KTKOrderDescending;

/**
 KTKPaging is a protocol that should be implemented by any object that represents Paging.
 */
@protocol KTKPaging <NSObject>

/**
 Paging start index
 */
@property (nonatomic, readonly) NSUInteger indexStart;

/**
 Paging max results
 */
@property (nonatomic, readonly) NSUInteger maxResults;

/**
 Paging previous results link
 */
@property (nonatomic, readonly) NSString *resultsPrevious;

/**
 Paging next results link
 */
@property (nonatomic, readonly) NSString *resultsNext;

/**
 Paging request results order by descriptor(asc/desc)
 */
@property (nonatomic, readonly) NSString *order;

@end


/**
 KTKPaging is BASE class representing Paging for collections(beacons, venues etc.).
 */
@interface KTKPaging : NSObject <KTKPaging, NSCopying>

@property (nonatomic) NSUInteger indexStart;
@property (nonatomic) NSUInteger maxResults;
@property (nonatomic) NSString *resultsPrevious;
@property (nonatomic) NSString *resultsNext;
@property (nonatomic, readonly) NSString *order;

/**
 Initializes new KTKPaging object with specified index start and max results
 
 @param indexStart  paged beacons start index
 @param maxResults  paged beacons max results
 
 @return KTKPaging object
 */
- (id)initWithIndexStart:(NSUInteger)indexStart andMaxResults:(NSUInteger)maxResults;

/**
 Changes request results order to ASCending
 */
- (void)changeOrderToAscending;

/**
 Changes request results order to DESCending
 */
- (void)changeOrderToDescending;

@end
