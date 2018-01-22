//
//  ViewController.swift
//  SampleSwift
//
//  Created by qbuser on 30/01/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.
//

import UIKit
import SwiftLoggly

class ViewController: UIViewController {

  
    @IBOutlet var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // Do any additional setup after loading the view, typically from a nib.
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let logsDirectory = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("logs", isDirectory: true)
        Loggly.logger.directory = logsDirectory.path
        Loggly.logger.enableEmojis = true
        loggly(LogType.Info, text: "Welcome to Swift Loggly")
        loggly(LogType.Verbose, text: "Fun")
        
        loggly(LogType.Debug, text: "is")
        loggly(LogType.Warnings, text: "Matter")
        loggly(LogType.Error, text: "here!!")
        
        

    }
    @IBAction func infoAction(_ sender: Any) {
        // First User Object
        let user1:NSMutableDictionary = NSMutableDictionary()
        user1.setObject("vignesh", forKey: "name" as NSCopying);
        user1.setObject("vigneshuvi@gmail.com", forKey: "email" as NSCopying);
        
        loggly(LogType.Info, dictionary: user1)
    }
    @IBAction func errorAction(_ sender: Any) {
        // First User Object
        let user1:NSMutableDictionary = NSMutableDictionary()
        user1.setObject("vignesh", forKey: "name" as NSCopying);
        user1.setObject("vigneshuvi@gmail.com", forKey: "email" as NSCopying);
        
        loggly(LogType.Error, dictionary: user1)
    }

    @IBAction func warnAction(_ sender: Any) {
        // First User Object
        let user1:NSMutableDictionary = NSMutableDictionary()
        user1.setObject("vignesh", forKey: "name" as NSCopying);
        user1.setObject("vigneshuvi@gmail.com", forKey: "email" as NSCopying);
        
        loggly(LogType.Warnings, dictionary: user1)
    }
    
    @IBAction func verboseAciton(_ sender: Any) {
        // First User Object
        let user1:NSMutableDictionary = NSMutableDictionary()
        user1.setObject("vignesh", forKey: "name" as NSCopying);
        user1.setObject("vigneshuvi@gmail.com", forKey: "email" as NSCopying);
        
        loggly(LogType.Verbose, dictionary: user1)
    }
    @IBAction func debugAction(_ sender: Any) {
        // First User Object
        let user1:NSMutableDictionary = NSMutableDictionary()
        user1.setObject("vignesh", forKey: "name" as NSCopying);
        user1.setObject("vigneshuvi@gmail.com", forKey: "email" as NSCopying);
        
        loggly(LogType.Debug, dictionary: user1)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

