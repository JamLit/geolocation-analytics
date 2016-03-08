//
//  Connectivity.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 05.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import Foundation
import CoreTelephony
import UIKit

enum RadioAccessTechnology: String {
    case NOTCONNECTED = "Not connected"
    case GPRS         = "GPRS"
    case EDGE         = "Edge"
    case WCDMA        = "WCDMA"
    case HSDPA        = "HSDPA"
    case HSUPA        = "HSUPA"
    case CDMA1X       = "CDMA1x"
    case CDMAEVDOREV0 = "CDMAEVDORev0"
    case CDMAEVDOREVA = "CDMAEVDORevA"
    case CDMAEVDOREVB = "CDMAEVDORevB"
    case EHRPD        = "eHRPD"
    case LTE          = "LTE"
    
    init(tech: String?) {
        guard let tech = tech else {
            self = .NOTCONNECTED
            return
        }
        
        switch tech {
        case CTRadioAccessTechnologyGPRS:         self = .GPRS
        case CTRadioAccessTechnologyEdge:         self = .EDGE
        case CTRadioAccessTechnologyWCDMA:        self = .WCDMA
        case CTRadioAccessTechnologyHSDPA:        self = .HSDPA
        case CTRadioAccessTechnologyHSUPA:        self = .HSUPA
        case CTRadioAccessTechnologyCDMA1x:       self = .CDMA1X
        case CTRadioAccessTechnologyCDMAEVDORev0: self = .CDMAEVDOREV0
        case CTRadioAccessTechnologyCDMAEVDORevA: self = .CDMAEVDOREVA
        case CTRadioAccessTechnologyCDMAEVDORevB: self = .CDMAEVDOREVB
        case CTRadioAccessTechnologyeHRPD:        self = .EHRPD
        case CTRadioAccessTechnologyLTE:          self = .LTE
        default:                                  self = .NOTCONNECTED
        }
    }
}

protocol ConnectivityDelegate {
    
    func connectivityDidUpdate(
        raTech raTech: RadioAccessTechnology,
        radioSignalStrength: Int,
        radioSignalStrengthBars: Int,
        carrierName: String,
        wifiEnabled: Bool,
        wifiConnected: Bool,
        wifiSSID: String,
        wifiSignalStrength: Int,
        wifiSignalStrengthBars: Int)
}

class Connectivity: NSObject {
    
    var delegate: ConnectivityDelegate? {
        didSet {
            update()
        }
    }
    
    var timer: NSTimer? = nil
    
    func update() {
        if let delegate = delegate {
            delegate.connectivityDidUpdate(
                raTech: radioAccessTechnology,
                radioSignalStrength: radioSignalStrength,
                radioSignalStrengthBars:radioSignalStrengthBars,
                carrierName: carrierName,
                wifiEnabled: wifiEnabled,
                wifiConnected: wifiConnected,
                wifiSSID: wifiSSID,
                wifiSignalStrength: wifiSignalStrength,
                wifiSignalStrengthBars: wifiSignalStrengthBars)
            
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:"update", userInfo:nil, repeats:false)
        }
    }
    
    var radioAccessTechnology: RadioAccessTechnology {
        return RadioAccessTechnology(tech: CTTelephonyNetworkInfo().currentRadioAccessTechnology)
    }
    
    var radioSignalStrength: Int {
        return getIntValueForBarItem(.SignalStrengthItemView, value: .SignalStrengthRaw)
    }
    
    var radioSignalStrengthBars: Int {
        return getIntValueForBarItem(.SignalStrengthItemView, value: .SignalStrengthBars)
    }
    
    var carrierName: String {
        let carrier = CTTelephonyNetworkInfo().subscriberCellularProvider
        
        guard let carrierName = carrier?.carrierName else {
            return "Unknown"
        }
        
        return carrierName
    }
    
    var wifiEnabled: Bool {
        return MWFWifiHelpers().isWiFiEnabled()
    }
    
    var wifiConnected: Bool {
        return MWFWifiHelpers().isWiFiConnected()
    }
    
    var wifiSSID: String {
        return MWFWifiHelpers().SSID() ?? "Unknown"
    }
    
    var wifiSignalStrength: Int {
        return getIntValueForBarItem(.WifiStrengthItemView, value: .WifiStrengthRaw)
    }
    
    var wifiSignalStrengthBars: Int {
        return getIntValueForBarItem(.WifiStrengthItemView, value: .WifiStrengthBars)
    }
}

// MARK: Private helpers

private extension Connectivity {
    
    enum StatusBarKey: String {
        case SignalStrengthItemView = "UIStatusBarSignalStrengthItemView"
        case SignalStrengthRaw      = "signalStrengthRaw"
        case SignalStrengthBars     = "signalStrengthBars"
        case WifiStrengthItemView   = "UIStatusBarDataNetworkItemView"
        case WifiStrengthRaw        = "wifiStrengthRaw"
        case WifiStrengthBars       = "wifiStrengthBars"
    }

    func getStatusBarSubviews() -> [UIView] {
        let app = UIApplication.sharedApplication()
        guard let subviews = app.valueForKey("statusBar")?.valueForKey("foregroundView")?.subviews else {
            return []
        }
        return subviews
    }
    
    func getIntValueForBarItem(barItem: StatusBarKey, value: StatusBarKey) -> Int {
        var signalStrength = 0
        let subviews = getStatusBarSubviews()
        for subview in subviews {
            if let itemClass = NSClassFromString(barItem.rawValue) {
                if subview.isKindOfClass(itemClass), let subViewKey = subview.valueForKey(value.rawValue)  {
                    signalStrength = subViewKey.integerValue
                    break
                }
            }
        }
        return signalStrength
    }
}