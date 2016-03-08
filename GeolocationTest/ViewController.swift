//
//  ViewController.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 04.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import UIKit
import CoreLocation
import Eureka
import FileKit

class ViewController: FormViewController, ApplicationStateObservable {
    
    lazy var locationManager = { return LocationManager.sharedInstance }()
    lazy var connectivity    = { return Connectivity() }()
    lazy var logging         = { return Logging.sharedInstance }()
    
    var applicationState = UIApplicationState.Foreground
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Init Eureka form
        initFormTheme()
        initForm()
        
        // Initial location manager settings
        locationManager.delegate = self
        
        // Initial connectivity client settings
        connectivity.delegate = self
        
        // Start application state observers
        startApplicationStateObservation()
    }
    
    
    // Declarations in extensions cannot override yet :(
    override func rowValueHasBeenChanged(row: BaseRow, oldValue: Any?, newValue: Any?) {
        row.updateCell()
    }
}


// MARK: Eureka form

extension ViewController {
    
    func initFormTheme() {
        ButtonRow.defaultCellUpdate = {
            cell, row in
            cell.textLabel?.font = UIFont.systemFontOfSize(14, weight: 0.0)
        }
        LabelRow.defaultCellUpdate = {
            cell, row in
            cell.textLabel?.font = UIFont.systemFontOfSize(14, weight: 0.0)
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(14, weight: 0.1)
        }
        PopoverSelectorRow<Double>.defaultCellUpdate = {
            cell, row in
            cell.textLabel?.font = UIFont.systemFontOfSize(14, weight: 0.0)
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(14, weight: 0.1)
        }
        PopoverSelectorRow<String>.defaultCellUpdate = {
            cell, row in
            cell.textLabel?.font = UIFont.systemFontOfSize(14, weight: 0.0)
            cell.detailTextLabel?.font = UIFont.systemFontOfSize(14, weight: 0.1)
        }
    }

    func initForm() {
        
        form
            +++ Section("radio")
            <<< LabelRow("radioAccessTech") {
                $0.title = "Radio Access Tech"
                $0.value = "XXX"
            }
            <<< LabelRow("radioSignalStrength") {
                $0.title = "Signal strength"
                $0.value = "XXX"
            }
            <<< LabelRow("radioSignalStrengthBars") {
                $0.title = "Signal strength (bars)"
                $0.value = "XXX"
            }
            <<< LabelRow("carrier") {
                $0.title = "Carrier"
                $0.value = "XXX"
            }
            
            +++ Section("wifi")
            <<< LabelRow("wifiStatus") {
                $0.title = "Wifi"
                $0.value = "XXX"
            }
            <<< LabelRow("wifiSSID") {
                $0.title = "Wifi SSID"
                $0.value = "XXX"
            }
            <<< LabelRow("wifiSignalStrength") {
                $0.title = "Signal strength"
                $0.value = "XXX"
            }
            <<< LabelRow("wifiSignalStrengthBars") {
                $0.title = "Signal strength (bars)"
                $0.value = "XXX"
            }
            
            +++ Section("Location Manager Values")
            
            <<< LabelRow("latLon") {
                $0.title = "Lat / Lon"
                $0.value = "XXX"
            }
            <<< LabelRow("accuracy") {
                $0.title = "Accuracy"
                $0.value = "XXX"
            }
            <<< LabelRow("lastUpdated") {
                $0.title = "Last updated"
                $0.value = "XXX"
            }
            <<< LabelRow("locationStatus") {
                $0.title = "Location services"
                $0.value = CLLocationManager.locationServicesEnabled() ? "Enabled" : "Disabled"
            }
            <<< LabelRow("authStatus") {
                $0.title = "Auth. status"
                $0.value = CLLocationManager.authorizationStatus().stringValue()
            }
            
            +++ Section("Settings")
            
            <<< PopoverSelectorRow<Double>("distanceFilter") {
                $0.title = "Distance filter"
                $0.options = [0, 100, 200, 300, 400, 500, 1000, 1500, 2000]
                $0.value = self.locationManager.distanceFilter
                $0.selectorTitle = "Choose the distance filter (meters)"
                }.onChange({ row -> () in
                    self.locationManager.distanceFilter = Double(row.value!)
                })
            <<< PopoverSelectorRow<String>("accuracySetting") {
                $0.title = "Accuracy"
                $0.options = LocationAccuracy.allValues
                $0.value = locationManager.desiredAccuracy.rawValue
                $0.selectorTitle = "Choose the accuracy"
                }.onChange({ row -> () in
                    self.locationManager.desiredAccuracy = LocationAccuracy.init(raw: row.value!)!
                })
            
            +++ Section("")
            <<< ButtonRow("trackingButton") {
                $0.title = locationManager.trackingState.toButtonTitle()
                }.onCellSelection({ (cell, row) -> () in
                    self.locationManager.toggleLocationUpdates()
                })
    }
}

// MARK: Location delegate

extension ViewController: LocationDelegate {
    
    func didUpdateLocation(location: CLLocation, lastUpdated: NSDate, accuracy: Double) {
        guard applicationState == .Foreground else {
            return
        }
        
        form.setValues([
            "latLon"      : Formatter.shortLocationString(location),
            "lastUpdated" : Formatter.shortDateTimeString(lastUpdated),
            "accuracy"    : "\(accuracy)"
            ])
        tableView!.reloadData()
    }
    
    func didFailWithError(error: NSError) {
        let alertController = UIAlertController(title: "Location updates failed", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action -> Void in
        }))
        alertController.addAction(UIAlertAction(title: "Retry", style: UIAlertActionStyle.Default, handler: { action -> Void in
            self.locationManager.startLocationUpdates()
        }))
        presentViewController(alertController, animated: true) { () -> Void in
            
        }
    }
    
    func didChangeAuthStatus(status: CLAuthorizationStatus) {
        form.setValues(["authStatus" : status.stringValue()])
    }
    
    func didChangeTrackingState(state: LocationTrackingState) {
        if let trackingButton = form.rowByTag("trackingButton") {
            trackingButton.title = state.toButtonTitle()
            trackingButton.updateCell()
        }
        
        switch state {
        case .Tracking:
            logging.startLogging()
        case .Idle, .AwaitingAuth:
            logging.stopLogging()
        }
    }
}

// MARK: Connectivity delegate

extension ViewController: ConnectivityDelegate {
    
    func connectivityDidUpdate(
        raTech raTech: RadioAccessTechnology,
        radioSignalStrength: Int,
        radioSignalStrengthBars: Int,
        carrierName: String,
        wifiEnabled: Bool,
        wifiConnected: Bool,
        wifiSSID: String,
        wifiSignalStrength: Int,
        wifiSignalStrengthBars: Int) {
            
            guard applicationState == .Foreground else {
                return
            }
            
            let wifiEnabledString = wifiEnabled ? "Enabled" : "Disabled"
            let wifiConnectedString = wifiConnected ? "connected" : "disconnected"
        
            form.setValues([
                "radioAccessTech"        : raTech.rawValue,
                "radioSignalStrength"    : "\(radioSignalStrength)",
                "radioSignalStrengthBars": "\(radioSignalStrengthBars)",
                "carrier"                : carrierName,
                "wifiStatus"             : "\(wifiEnabledString) and \(wifiConnectedString)",
                "wifiSSID"               : wifiSSID,
                "wifiSignalStrength"     : "\(wifiSignalStrength)",
                "wifiSignalStrengthBars" : "\(wifiSignalStrengthBars)"
            ])
    }
}

// MARK: Application state observation

extension ViewController {
    func startApplicationStateObservation() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEnterBackground"), name:UIApplicationDidEnterBackgroundNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didEnterForeground"), name:UIApplicationDidBecomeActiveNotification, object: nil)
    }
    
    func didEnterBackground() {
        applicationState = .Background
    }
    
    func didEnterForeground() {
        applicationState = .Foreground
    }
}
