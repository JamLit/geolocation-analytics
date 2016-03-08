//
//  LoggingDataProvider.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 07.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import Foundation
import UIKit
import FileKit

class LoggingDataProvider: NSObject {
    let cellIdentifier = "standardCell"
}

// MARK: Data source

extension LoggingDataProvider: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Logging.files.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        cell?.textLabel?.font = UIFont.systemFontOfSize(14, weight: 0.0)
        cell?.detailTextLabel?.font = UIFont.systemFontOfSize(12, weight: 0.1)
        cell?.detailTextLabel?.textColor = UIColor.lightGrayColor()
        cell?.accessoryType = .DisclosureIndicator
        
        let file: Path = Logging.files[indexPath.row];
        cell?.textLabel?.text = "Logfile \(Formatter.shortDateTimeString(file.fileName))"
        cell?.detailTextLabel?.text = "\(file.fileName) (\(file.fileSize! / 1024) kB)"
        
        return cell!
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            do {
                try Logging.deleteFile(indexPath.row)
            } catch {
                print("Could not delete file")
                return
            }
            tableView.beginUpdates()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
    }
}