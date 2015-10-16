//
//  KontaktSDK.h
//  kontakt-ios-sdk
//
//  Created by Krzysiek Cieplucha on 03/03/14.
//  Copyright (c) 2014 kontakt.io. All rights reserved.
//


#define KONTAKT_SDK_VERSION @"6.2"

// API
#import "KTKClient.h"

// DTO
#import "KTKDevice.h"
#import "KTKBeacon.h"
#import "KTKPublicBeacon.h"
#import "KTKEddystone.h"
#import "KTKCloudBeacon.h"
#import "KTKBeaconProfile.h"
#import "KTKFirmware.h"
#import "KTKAction.h"
#import "KTKPublicAction.h"
#import "KTKRegion.h"
#import "KTKVenue.h"
#import "KTKPublicVenue.h"
#import "KTKCompany.h"
#import "KTKManager.h"
#import "KTKSubordinate.h"
#import "KTKUser.h"

// Converters
#import "KTKHexConverter.h"
#import "KTKNumberConverter.h"
#import "KTKNumberDiscreteConverter.h"
#import "KTKNumberLinearConverter.h"
#import "KTKStringConverter.h"
#import "KTKUUIDConverter.h"
#import "KTKEddystoneURLConverter.h"

// iBeacons
#import "KTKBeaconDevice.h"
#import "KTKBeaconManager.h"

// Eddystones
#import "KTKEddystoneDevice.h"
#import "KTKEddystoneRegion.h"
#import "KTKEddystoneUID.h"
#import "KTKEddystoneURL.h"
#import "KTKEddystoneTLM.h"

// Microlocation
#import "KTKActionManager.h"
#import "KTKLocationManager.h"

// Utils
#import "KTKError.h"
#import "KTKPagingBeacons.h"
#import "KTKPagingDevices.h"
#import "KTKPagingConfigs.h"
#import "KTKPagingVenues.h"
