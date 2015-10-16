//
//  KTKEddystoneURL.h
//  Eddystone
//
//  Created by Marek Serafin on 08/04/15.
//  Copyright (c) 2015 Kontakt.io. All rights reserved.
//

@import Foundation;
#import "KTKEddystoneFrame.h"

/**
 Represents KTKEddystone URL data frame
 */
@interface KTKEddystoneURL : NSObject <KTKEddystoneFrame>

/**
 M2M(machine-to-machine) flag is a command for the user-agent that tells it not to access or display the URL.
 This is a guideline only. User agents may, with user approval, display M2M URLs.
 */
@property (nonatomic, assign, readonly, getter=isMachineToMachine) BOOL machineToMachine;
/**
 Eddystone URL
 */
@property (nonatomic, strong, readonly) NSURL *url;

@end
