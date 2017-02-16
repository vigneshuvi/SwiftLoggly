//
//  LogglyTests.swift
//  SwiftLoggly
//
//  Created by Vignesh on 30/01/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.
//


@testable import Loggly
import XCTest

class LogglyTests: XCTestCase {
    
    func testLogglyTypes() {
        loggly(LogType.Info, text: "Welcome to Swift Loggly")
        loggly(LogType.Verbose, text: "Fun")
        
        loggly(LogType.Debug, text: "is")
        loggly(LogType.Warnings, text: "Matter")
        loggly(LogType.Error, text: "here!!")
    }
    
}
