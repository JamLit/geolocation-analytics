//
//  LocationEnums.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 06.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import Foundation
import CoreLocation

enum LocationAccuracy : String {
    case BestForNavigation = "Best for navigation"
    case Best              = "Best"
    case NearestTenMeters  = "Nearest ten meters"
    case HundredMeters     = "Hundred meters"
    case Kilomter          = "Kilometer"
    case ThreeKilometers   = "Three Kilometers"
    
    static let allValues = [
        "Best for navigation",
        "Best",
        "Nearest ten meters",
        "Hundred meters",
        "Kilometer",
        "Three Kilometers"
    ]
    
    init?(raw: String) {
        self.init(rawValue: raw)
    }
    
    func toCLLocationAccuracy() -> Double {
        switch self {
        case .BestForNavigation:
            return kCLLocationAccuracyBestForNavigation
        case .Best:
            return kCLLocationAccuracyBest
        case .HundredMeters:
            return kCLLocationAccuracyHundredMeters
        case .Kilomter:
            return kCLLocationAccuracyKilometer
        case .NearestTenMeters:
            return kCLLocationAccuracyNearestTenMeters
        case .ThreeKilometers:
            return kCLLocationAccuracyThreeKilometers
        }
    }
}

extension CLAuthorizationStatus {
    func stringValue() -> String {
        var status: String
        
        switch self {
        case .NotDetermined:
            status = "Not determined"
            break
        case .Denied:
            status = "Denied"
            break
        case .Restricted:
            status = "Restricted"
            break
        case .AuthorizedAlways:
            status = "Always"
            break
        case .AuthorizedWhenInUse:
            status = "When in use"
            break
        }
        
        return status
    }
}