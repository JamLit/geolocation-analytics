//
//  LocationManager.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 07.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import UIKit
import CoreLocation

enum LocationTrackingState {
    case Idle
    case AwaitingAuth
    case Tracking
    
    func toButtonTitle() -> String {
        switch self {
        case .Idle:
            return "Start location updates"
        case .AwaitingAuth:
            return "Awaiting authorization"
        case .Tracking:
            return "Stop location updates"
        }
    }
}

protocol LocationDelegate {
    func didUpdateLocation(location: CLLocation, lastUpdated: NSDate, accuracy: Double)
    func didFailWithError(error: NSError)
    func didChangeAuthStatus(status: CLAuthorizationStatus)
    func didChangeTrackingState(state: LocationTrackingState)
}

class LocationManager: NSObject {
    
    static let sharedInstance = LocationManager()
    
    var delegate: LocationDelegate?
    
    private (set) var trackingState = LocationTrackingState.Idle
    
    private lazy var locationManager = { return CLLocationManager() }()
    
    var desiredAccuracy = LocationAccuracy.Best {
        didSet {
            locationManager.desiredAccuracy = desiredAccuracy.toCLLocationAccuracy()
        }
    }
    
    var distanceFilter = 0.0 {
        didSet {
            locationManager.distanceFilter = distanceFilter
        }
    }
    
    private (set) var location: CLLocation = CLLocation()
    
    private (set) var accuracy: CLLocationAccuracy = 0.0
    
    private (set) var lastUpdated: NSDate = NSDate()
    
    override private init() {
        super.init()
        locationManager.delegate = self
    }
}

extension LocationManager {
    
    func toggleLocationUpdates() {
        switch trackingState {
        case .Idle, .AwaitingAuth:
            startLocationUpdates()
        case .Tracking:
            stopLocationUpdates()
        }
    }
    
    func startLocationUpdates() {
        switch CLLocationManager.authorizationStatus() {
        case .NotDetermined, .AuthorizedWhenInUse:
            trackingState = .AwaitingAuth
            locationManager.requestAlwaysAuthorization()
        case .Denied, .Restricted:
            trackingState = .Idle
            locationManager.stopUpdatingLocation()
        case .AuthorizedAlways:
            trackingState = .Tracking
            locationManager.startUpdatingLocation()
        }
        delegate?.didChangeTrackingState(trackingState)
    }
    
    func stopLocationUpdates() {
        trackingState = .Idle
        locationManager.stopUpdatingLocation()
        delegate?.didChangeTrackingState(trackingState)
    }
}

// MARK: CLLocationManager delegate

extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            self.location = location
            self.lastUpdated = location.timestamp
            self.accuracy = location.horizontalAccuracy
            delegate?.didUpdateLocation(location, lastUpdated: location.timestamp, accuracy: location.horizontalAccuracy)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        delegate?.didFailWithError(error)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if trackingState == .AwaitingAuth && status == .AuthorizedAlways {
            locationManager.startUpdatingLocation()
            trackingState = .Tracking
            delegate?.didChangeTrackingState(trackingState)
        }
        delegate?.didChangeAuthStatus(status)
    }
}