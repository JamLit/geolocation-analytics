//
//  LogfileDetailViewController.swift
//  GeolocationTest
//
//  Created by Martin Wildfeuer on 07.03.16.
//  Copyright © 2016 mwfire development. All rights reserved.
//

import UIKit
import FileKit
import MessageUI

class LogfileDetailViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var file: Path?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.editable = false
        
        let emailButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action:"composeEmail")
        navigationItem.rightBarButtonItem = emailButton
        
        if let file = file {
            textView.text = Logging.stringFromFile(file)
        }
    }
    
    func composeEmail() {
        guard MFMailComposeViewController.canSendMail() else {
            print("Cant send mail")
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setSubject("Geolocation Analytics log")
        
        guard let file = file else {
            return
        }
        
        guard let data = NSData(contentsOfFile: file.rawValue) else {
            return
        }
        
        composer.addAttachmentData(data, mimeType: "text/plain", fileName: file.fileName)
        presentViewController(composer, animated: true, completion: nil)
    }
}

extension LogfileDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
