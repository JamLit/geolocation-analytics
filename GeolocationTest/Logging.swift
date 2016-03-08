//
//  Logging.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 06.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import UIKit
import FileKit

enum LogFileError: String, ErrorType {
    case DeletionFailed = "Could not delete file"
}

class Logging: NSObject {
    
    static let sharedInstance = Logging()
    
    lazy var connectivity: Connectivity = {
        return Connectivity()
    }()
    
    lazy var location: LocationManager = {
        return LocationManager.sharedInstance
    }()
    
    var logFile: TextFile?
    
    var timer: NSTimer? = nil
    
    private override init() {}
    
    static var logFilesPath: Path? {
        return Path.UserTemporary
    }
    
    func startLogging() {
        guard timer == nil else {
            return
        }
        
        guard let path = Logging.logFilesPath else {
            return
        }
        
        let timestamp = NSDate().timeIntervalSince1970
        logFile = TextFile(path: path + "\(timestamp).txt")
        logDeviceData()
        logSeparator()
        logEvent()
    }
    
    func stopLogging() {
        if let timer = timer {
            timer.invalidate()
        }
        timer = nil
    }
    
    func logString(string: String) {
        guard let logFile = logFile else {
            return
        }
        
        do {
            try string |>> logFile
        } catch {
            print("Error")
        }
    }
    
    func logEvent() {
        logTime()
        logConnectivity()
        logLocation()
        logSeparator()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target:self, selector:"logEvent", userInfo:nil, repeats:false)
    }
}


// MARK: CRUD

extension Logging {
    
    /// Get all logfiles
    static var files: [Path] {
        guard let path = Logging.logFilesPath else {
            return []
        }
        
        let files = path.find(searchDepth: 1) { path in
            path.pathExtension == "txt"
        }
        return files
    }
    
    // Get file at given index
    static func file(index: Int) -> Path {
        let file = Logging.files[index]
        return file
    }
    
    // Delete logFile at index
    static func deleteFile(index: Int) throws {
        let file = Logging.files[index]
        do {
            try file.deleteFile()
        } catch {
            throw LogFileError.DeletionFailed
        }
    }
    
    static func stringFromFile(index: Int) -> String {
        let file = Logging.file(index)
        return Logging.stringFromFile(file)
    }
    
    static func stringFromFile(file: Path) -> String {
        if let data = try? TextFile(path: file).read() {
            return String(data)
        }
        
        return ""
    }
}

// MARK: String logging

private extension Logging {
    
    func logSeparator() {
        logString("\n")
    }
    
    func logDeviceData() {
        let device = UIDevice.currentDevice()
        var string = ""
        string += "Device: \(device.name) \(device.model), \(device.systemName) - \(device.systemVersion)\n"
        string += "Batt: \(device.batteryLevel)"
        logString(string)
    }
    
    func logTime() {
        let date = NSDateFormatter.localizedStringFromDate(NSDate(), dateStyle: .ShortStyle, timeStyle: .MediumStyle)
        logString("\(date)")
    }
    
    func logConnectivity() {
        let wifiEnabledString = connectivity.wifiEnabled ? "En" : "Dis"
        let wifiConnectedString = connectivity.wifiConnected ? "Conn" : "Dis"
        
        var string = ""
        string += "RAT: \(connectivity.radioAccessTechnology.rawValue)\n"
        string += "RStr: \(connectivity.radioSignalStrength)\n"
        string += "WifiEn: \(wifiEnabledString)\n"
        string += "WifiConn: \(wifiConnectedString)\n"
        string += "WifiStr: \(connectivity.wifiSignalStrength)"
        
        logString(string)
    }
    
    func logLocation() {
        var string = ""
        string += "LatLon: \(Formatter.shortLocationString(location.location))\n"
        string += "Upd: \(Formatter.shortDateTimeString(location.lastUpdated))\n"
        string += "Acc: \(location.accuracy)\n"
        string += "+DesAcc: \(location.desiredAccuracy.rawValue)\n"
        string += "+Filt: \(location.distanceFilter)"
        logString(string)
    }
}
