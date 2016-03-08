//
//  MWFWifiHelpers.m
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 05.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

#import "MWFWifiHelpers.h"
#import <ifaddrs.h>
#import <net/if.h>
#import <SystemConfiguration/CaptiveNetwork.h>


@implementation MWFWifiHelpers


- (BOOL) isWiFiEnabled {
    
    NSCountedSet * cset = [NSCountedSet new];
    
    struct ifaddrs *interfaces;
    
    if( ! getifaddrs(&interfaces) ) {
        for( struct ifaddrs *interface = interfaces; interface; interface = interface->ifa_next) {
            if ( (interface->ifa_flags & IFF_UP) == IFF_UP ) {
                [cset addObject:[NSString stringWithUTF8String:interface->ifa_name]];
            }
        }
    }
    
    return [cset countForObject:@"awdl0"] > 1 ? YES : NO;
}

// Xcode warns us to use NEHotspotHelper, but this needs
// permission from Apple, we had to mail them our request
- (NSDictionary *) wifiDetails {
    #if (TARGET_IPHONE_SIMULATOR)
    return nil;
    #endif
    
    return
    (__bridge NSDictionary *)
    CNCopyCurrentNetworkInfo(
                             CFArrayGetValueAtIndex( CNCopySupportedInterfaces(), 0)
                             );
}

- (BOOL) isWiFiConnected {
    return [self wifiDetails] == nil ? NO : YES;
}

- (NSString *) BSSID {
    return [self wifiDetails][@"BSSID"];
}

- (NSString *) SSID {
    return [self wifiDetails][@"SSID"];
}


@end
