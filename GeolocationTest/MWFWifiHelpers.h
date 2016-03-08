//
//  MWFWifiHelpers.h
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 05.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

#import <Foundation/Foundation.h>

// http://www.enigmaticape.com/blog/determine-wifi-enabled-ios-one-weird-trick

@interface MWFWifiHelpers : NSObject
- (BOOL)       isWiFiEnabled;
- (BOOL)       isWiFiConnected;
- (NSString * _Nullable) BSSID;
- (NSString * _Nullable) SSID;
@end
