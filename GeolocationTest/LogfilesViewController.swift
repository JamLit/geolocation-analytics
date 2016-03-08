//
//  LogfilesViewController.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 07.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import UIKit

class LogfilesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    lazy var dataProvider = {
       return LoggingDataProvider()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 80
        tableView.dataSource = dataProvider
        tableView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
}

// MARK: TableView delegate

extension LogfilesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("logfileDetail", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destination = segue.destinationViewController as! LogfileDetailViewController
        if let indexPath = sender as? NSIndexPath {
            destination.file = Logging.file(indexPath.row)
        }
    }
}