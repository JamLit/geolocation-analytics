//
//  Formatter.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 05.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import Foundation
import CoreLocation
import CoreTelephony
import FileKit

struct Formatter {
    
    static func shortLocationString(location: CLLocation) -> String {
        let lat = String(format: "%.5f", location.coordinate.latitude)
        let lon = String(format: "%.5f", location.coordinate.longitude)
        return "\(lat) / \(lon)"
    }
    
    static func shortDateTimeString(date: NSDate) -> String {
        return NSDateFormatter.localizedStringFromDate(date, dateStyle: .ShortStyle, timeStyle: .MediumStyle)
    }
    
    static func shortDateTimeString(fileName: String) -> String {
        guard let timestamp = Double((fileName as NSString).stringByDeletingPathExtension) else {
            return ""
        }
        
        let date = NSDate(timeIntervalSince1970: timestamp)
        return shortDateTimeString(date)
    }
    
}
