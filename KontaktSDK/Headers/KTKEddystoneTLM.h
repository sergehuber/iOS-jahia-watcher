//
//  KTKEddystoneTLM.h
//  Eddystone
//
//  Created by Marek Serafin on 08/04/15.
//  Copyright (c) 2015 Kontakt.io. All rights reserved.
//

@import Foundation;
#import "KTKEddystoneFrame.h"

/**
 Represents KTKEddystone TLM(telemetric) data frame
 */
@interface KTKEddystoneTLM : NSObject <KTKEddystoneFrame>

/**
 TLM version provides for future extension.
 */
@property (nonatomic, assign, readonly) NSUInteger version;

/**
 Eddystone device battery voltage - 1mv / bit
 */
@property (nonatomic, assign, readonly) NSInteger batteryVoltage;
/**
 Temperature that is recorded by Eddystone
 */
@property (nonatomic, assign, readonly) float temperature;

/**
 Advertising PDU Count - Running count of PDUs emitted from Beacon since Beacon power-up or reboot
 */
@property (nonatomic, assign, readonly) NSInteger advertisingCount;
/**
 Represents time since Beacon power-up or reboot
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeIntervalSincePowerUp;

@end
