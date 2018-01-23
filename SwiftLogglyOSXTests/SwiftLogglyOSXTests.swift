//
//  SwiftLogglyOSXTests.swift
//  SwiftLogglyOSXTests
//
//  Created by Vignesh on 30/01/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.
//

import XCTest
@testable import SwiftLogglyOSX

class SwiftLogglyOSXTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let logsDirectory = URL(fileURLWithPath: documentsDirectory).appendingPathComponent("vignesh", isDirectory: true)
        Loggly.logger.directory = logsDirectory.path
        Loggly.logger.enableEmojis = true
        Loggly.logger.logFormatType = LogFormatType.Normal
        
        Loggly.logger.logEncodingType = String.Encoding.utf8;
        
        loggly(LogType.Info, text: "Welcome to Swift Loggly")
        loggly(LogType.Verbose, text: "Fun")
        
        loggly(LogType.Debug, text: "is")
        loggly(LogType.Warnings, text: "Matter")
        loggly(LogType.Error, text: "here!!")
        
        print(getLogglyReportsOutput());
        loggly(LogType.Debug, text: "is")
        loggly(LogType.Warnings, text: "Matter")
        loggly(LogType.Error, text: "here!!")
        
        print(getLogglyReportsOutput());
        
        loggly(LogType.Debug, text: "is")
        loggly(LogType.Warnings, text: "Matter")
        loggly(LogType.Error, text: "here!!")
        
        print(getLogCountBasedonType(LogType.Warnings));
        
        let dict:NSMutableDictionary = NSMutableDictionary();
        dict.setValue("Vignesh", forKey: "name") ;
        dict.setValue("Senior Engineer",forKey: "Position");
        
        
        loggly(LogType.Info, dictionary: dict)
        
        
        
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
