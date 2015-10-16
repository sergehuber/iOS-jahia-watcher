//
//  KTKError.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 25/02/14.
//  Copyright (c) 2014 kontakt. All rights reserved.
//

/**
 Possible error codes of KTKError.
 */
typedef NS_ENUM(int, KTKErrorCode) {
    /**
     Error cause is unknown.
     */
    KTKErrorCodeUnknown = 0,
    
    /**
     Connection to web API failed.
     */
    KTKErrorCodeConnectionFailed = 1,
    
    /**
     Web API responded with 4xx - client error
     */
    KTKErrorCodeClientError = 2,
    
    /**
     Web API responded with 403 - forbidden access
     */
    KTKErrorCodeResourceForbidden = 3,
    
    /**
     Web API didn't found requested resource.
     */
    KTKErrorCodeResourceNotFound = 4,
    
    /**
     Web API responded with 422 - validation error
     */
    KTKErrorCodeValidationFailed = 5,
    
    /**
     Web API responded with 5xx - server error
     */
    KTKErrorCodeServerError = 6,
    
    /**
     KTKConverter did failed to convert value.
     */
    KTKErrorCodeConversionFailed = 7,
    
    /**
     Bluetooth device is not connected.
     */
    KTKErrorCodeDeviceDisconnected = 8,
    
    /**
     Bluetooth device is not connectable.
     */
    KTKErrorCodeDeviceLocked = 9,
    
    /**
     Bluetooth operation has failed.
     */
    KTKErrorCodeOperationFailed = 10,
    
    /**
     Bluetooth operation has timed out.
     */
    KTKErrorCodeOperationItmedOut = 11,
};

/**
 This class represents error returned by SDK methods.
 */
@interface KTKError : NSError

#pragma mark - class methods

/**
 Checks if error is KTKError with provided error code.
 
 @param error error to be checked
 @param code error code
 @return YES if error is KTKError with specified error code
 */
+ (BOOL)doesError:(NSError *)error haveCode:(KTKErrorCode)code;

/**
 Creates and return new KTKError object with provided error code.
 
 @param code error code
 @return new KTKError object
 */
+ (KTKError *)errorWithCode:(KTKErrorCode)code;

#pragma mark - initializers

/**
 Initializes object with given error code.
 
 @param code error code
 @return initialized object
 */
- (id)initWithCode:(KTKErrorCode)code;

@end
