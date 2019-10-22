//
//  Loggly.swift
//  SwiftLoggly
//
//  Created by Vignesh on 30/01/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.
//

import Foundation


//MARK: -  Extension for String to find length
extension String {
    var length: Int {
        return self.count
    }
    func trim() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}

//MARK: -  Extension for convert Dictionary to String
extension Dictionary {
    var jsonString: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return  String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(jsonString)
    }
}


//MARK: -  Extension for convert NSDictionary to String
extension NSDictionary {
    var jsonString: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return  String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func printJson() {
        print(jsonString)
    }
}

//MARK: -  Struct for Color Log
struct ColorLog {
    
    static let ESCAPE = "\u{001B}["
    
    static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    static let RESET = ESCAPE + "0m"   // Clear any foreground or background color
    
    static func red<T>(object: T) {
        print("\(ESCAPE)31m\(object)\(RESET)")
    }
    
    static func green<T>(object: T) {
        print("\(ESCAPE)32m\(object)\(RESET)")
    }
    
    static func blue<T>(object: T) {
        print("\(ESCAPE)34m\(object)\(RESET)")
    }
    
    static func yellow<T>(object: T) {
        print("\(ESCAPE)33m\(object)\(RESET)")
    }
    
    static func purple<T>(object: T) {
        print("\(ESCAPE)35m\(object)\(RESET)")
    }
    
}

//MARK: -  Enumaration for log type
public enum LogType {
    case Info
    case Verbose
    case Warnings
    case Debug
    case Error
}

//MARK: -  Enumaration for log type
public enum LogFormatType {
    case Normal
    case JSON
}

//MARK: -  Loggly Class
@objc open class Loggly:NSObject {
    
    //MARK: -  Log Report Properties
    
    //The name of swift loggly report.
    var logReportName = "SwiftLogglyReport";
    
    //The field of  loggly report.
    var logReportFields:NSArray = ["Info", "Verbose", "Warnings", "Debug", "Error"]
    
    //The field of Info Count
    var logInfoCount:NSInteger = 0
    
    //The field of Verbose Count
    var logVerboseCount:NSInteger = 0
    
    //The field of Warnings Count
    var logWarnCount:NSInteger = 0
    
    //The field of Debug Count
    var logDebugCount:NSInteger = 0
    
    //The field of Error Count
    var logErrorCount:NSInteger = 0
    
    //MARK: -  Log Properties
    
    //The log encodeing format
    open var logEncodingType:String.Encoding = String.Encoding.utf8;
    
    //Log items saved format .
    open var logFormatType = LogFormatType.Normal;
    
    ///The max size a log file can be in Kilobytes. Default is 1024 (1 MB)
    open var maxFileSize: UInt64 = 1024;
    
    ///The max number of log file that will be stored. Once this point is reached, the oldest file is deleted.
    open var maxFileCount = 4;
    
    ///The directory in which the log files will be written
    open var directory : String = Loggly.defaultDirectory() {
        didSet {
            guard directory.count > 0 else {
                print("Error changing logger directory. The value \(directory) is not valid. Using default value instead")
                directory = Loggly.defaultDirectory()
                return
            }
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: directory)  {
                do {
                    try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: false, attributes: nil)
                } catch _ {
                    print("Error changing logger directory. The value \(directory) is not valid. Using default value instead")
                    directory = Loggly.defaultDirectory()
                }
            }
        }
    }
    
    ///The reportDirectory in which the report files will be written
    var reportDirectory = Loggly.defaultReportDirectory();
    
    //The name of the log files.
    open var name = "logglyfile";
    
    //The date format of the log time.
    open var logDateFormat = "";
    
    // Help to enble Emojis
    open var enableEmojis = false;
    
    
    // Log file extension
    open var logFileExtension = ".log"
    
    func getExtension() -> String {
        return logFileExtension.trim().length > 0 ? logFileExtension : ".log"
    }
    
    ///logging singleton
    open class var logger: Loggly {
        
        struct Static {
            static let instance: Loggly = Loggly()
        }
        Static.instance.loadLogCounts()
        return Static.instance
    }
    
    //MARK: -  Reports Util Methods
    
    ///gets the CSV name
    func getReportFileName() -> String {
        return "\(logReportName).csv"
    }
    
    // Set the Loggly Reports Name
    open func setLogglyReportsName(_ name: String){
        logReportName = name;
    }
    
    // Get the Loggly Reports Name
    open func getLogglyReportsName() -> String{
        return logReportName;
    }
    
    func loadLogCounts() {
        if logInfoCount == 0 && logVerboseCount == 0 && logWarnCount == 0 && logDebugCount == 0 && logErrorCount == 0 {
            self.loadLogDetails()
        }
    }
    
    func loadLogDetails() {
        let path = "\(reportDirectory)/\(self.getReportFileName())"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let logDict:NSMutableDictionary = self.readReports();
            if logDict.allKeys.count > 0 {
                let rows:NSArray = logDict.object(forKey: "rows") as! NSArray;
                if rows.count > 0 {
                    for dict in rows {
                        let row = dict as! NSDictionary
                        for key in row.allKeys {
                            switch (key as! String) {
                            case "Info":
                                logInfoCount = (row.object(forKey: key) as! NSString).integerValue;
                                break
                            case "Verbose":
                                logVerboseCount = (row.object(forKey: key) as! NSString).integerValue;
                                break
                            case "Warnings":
                                logWarnCount = (row.object(forKey: key) as! NSString).integerValue;
                                break
                            case "Debug":
                                logDebugCount = (row.object(forKey: key) as! NSString).integerValue;
                                break
                            case "Error":
                                logErrorCount = (row.object(forKey: key) as! NSString).integerValue;
                                break
                            default :
                                break
                            }
                            
                        }
                    }
                }
            }
        }
    }
    
    // Set the Loggly Reports Name
    func increaseLogCount(_  type: LogType){
        switch type {
        case .Info:
            logInfoCount += 1;
            break;
        case .Verbose:
            logVerboseCount += 1;
            break;
        case .Warnings:
            logWarnCount += 1;
            break;
        case .Debug:
            logDebugCount += 1;
            break;
        case .Error:
            logErrorCount += 1;
            break;
        }
        
        _ = self.createCSVReport(self.generateReportArray())
    }
    
    func generateReportArray() -> NSMutableArray {
        // Create Dictionary object for storing log count
        let logDictforCount:NSMutableDictionary = self.getReportsOutput()
        // CSV rows Array
        let data:NSMutableArray  = NSMutableArray()
        data.add(logDictforCount);
        return data;
    }
    
    open func getReportsOutput() -> NSMutableDictionary {
        
        // Create Dictionary object for storing log count
        let logDictforCount:NSMutableDictionary = NSMutableDictionary()
        logDictforCount.setValue(self.logInfoCount, forKey: "Info");
        logDictforCount.setValue(self.logVerboseCount, forKey: "Verbose" );
        logDictforCount.setValue(self.logWarnCount, forKey: "Warnings");
        logDictforCount.setValue(self.logDebugCount, forKey: "Debug");
        logDictforCount.setValue(self.logErrorCount, forKey: "Error");
        return logDictforCount;
    }
    
    // Get the Loggly Info Count
    open func getCountBasedonLogType(_ type: LogType) -> NSInteger{
        var count:NSInteger = 0;
        switch type {
        case .Info:
            count = self.getLogInfoCount();
            break;
        case .Verbose:
            count = self.getLogVerboseCount();
            break;
        case .Warnings:
            count = self.getLogWarningsCount();
            break;
        case .Debug:
            count = self.getLogDebugCount();
            break;
        case .Error:
            count = self.getLogErrorCount();
            break;
        }
        return count;
    }
    
    
    // Get the Loggly Info Count
    open func getLogInfoCount() -> NSInteger{
        return self.logInfoCount;
    }
    
    // Get the Loggly Verbose Count
    open func getLogVerboseCount() -> NSInteger{
        return self.logVerboseCount;
    }
    
    // Get the Loggly Warnings Count
    open func getLogWarningsCount() -> NSInteger{
        return self.logWarnCount;
    }
    
    // Get the Loggly Debug Count
    open func getLogDebugCount() -> NSInteger{
        return self.logDebugCount;
    }
    
    // Get the Loggly Error Count
    open func getLogErrorCount() -> NSInteger{
        return self.logErrorCount;
    }
    
    
    ///write content to the current csv file.
    open func getReportsFilePath() -> String{
        let path = "\(reportDirectory)/\(self.getReportFileName())"
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            return path;
        }
        return "";
    }
    
    func createCSVReport(_ values: NSArray) -> String {
        if logReportFields.count > 0 && values.count > 0 {
            let path = "\(reportDirectory)/\(self.getReportFileName())"
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: path) {
                do {
                    try "".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                } catch _ {
                }
            } else {
                do {
                    try "".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
                } catch _ {
                }
            }
            
            let  result:String = logReportFields.componentsJoined(by: ",");
            Loggly.logger.writeReports( text: result)
            for dict in values {
                let values = (dict as! NSDictionary).allValues as NSArray;
                let  result:String = values.componentsJoined(by: ",");
                Loggly.logger.writeReports( text: result)
            }
            return Loggly.logger.getReportsFilePath();
        }
        return "";
    }
    
    ///write content to the current csv file.
    open func writeReports(text: String) {
        let path = "\(reportDirectory)/\(self.getReportFileName())"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            do {
                try "".write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            } catch _ {
            }
        }
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            let writeText = "\(text)\n"
            fileHandle.seekToEndOfFile()
            fileHandle.write(writeText.data(using: String.Encoding.utf8)!)
            fileHandle.closeFile()
        }
    }
    
    open func readReports() -> NSMutableDictionary {
        let path = "\(reportDirectory)/\(self.getReportFileName())"
        return self.readFromPath(filePath:path);
    }
    
    /// read content to the current csv file.
    open func readFromPath(filePath: String) -> NSMutableDictionary{
        let fileManager = FileManager.default
        let output:NSMutableDictionary = NSMutableDictionary()
        
        // Find the CSV file path is available
        if fileManager.fileExists(atPath: filePath) {
            do {
                // Generate the Local file path URL
                let localPathURL: URL = NSURL.fileURL(withPath: filePath);
                
                // Read the content from Local Path
                let csvText = try String(contentsOf: localPathURL, encoding: String.Encoding.utf8);
                
                // Check the csv count
                if csvText.count > 0 {
                    
                    // Split based on Newline delimiter
                    let csvArray = self.splitUsingDelimiter(csvText, separatedBy: "\n") as NSArray
                    if csvArray.count >= 2 {
                        var fieldsArray:NSArray = [];
                        let rowsArray:NSMutableArray  = NSMutableArray()
                        for row in csvArray {
                            // Get the CSV headers
                            if((row as! String).contains(csvArray[0] as! String)) {
                                fieldsArray = self.splitUsingDelimiter(row as! String, separatedBy: ",") as NSArray;
                            } else {
                                // Get the CSV values
                                let valuesArray = self.splitUsingDelimiter(row as! String, separatedBy: ",") as NSArray;
                                if valuesArray.count == fieldsArray.count  && valuesArray.count > 0{
                                    let rowJson:NSMutableDictionary = self.generateDict(fieldsArray, valuesArray: valuesArray)
                                    if rowJson.allKeys.count > 0 && valuesArray.count == rowJson.allKeys.count && rowJson.allKeys.count == fieldsArray.count {
                                        rowsArray.add(rowJson)
                                    }
                                }
                            }
                        }
                        
                        // Set the CSV headers & Values and name in the dict.
                        if fieldsArray.count > 0 && rowsArray.count > 0 {
                            output.setObject(fieldsArray, forKey: "fields" as NSCopying)
                            output.setObject(rowsArray, forKey: "rows" as NSCopying)
                            output.setObject(localPathURL.lastPathComponent, forKey: "name" as NSCopying)
                        }
                    }
                }
            }
            catch {
                /* error handling here */
                print("Error while read csv: \(error)", terminator: "")
            }
        }
        return output;
    }
    
    func generateDict(_ fieldsArray: NSArray, valuesArray: NSArray ) -> NSMutableDictionary {
        let rowsDictionary:NSMutableDictionary = NSMutableDictionary()
        for i in 0..<valuesArray.count {
            let key = fieldsArray[i];
            let value = valuesArray[i];
            rowsDictionary.setObject(value, forKey: key as! NSCopying);
        }
        return rowsDictionary;
    }
    
    func splitUsingDelimiter(_ string: String, separatedBy: String) -> NSArray {
        if string.count > 0 {
            return string.components(separatedBy: separatedBy) as NSArray;
        }
        return [];
    }
    
    ///do the checks and cleanup
    open func cleanupReports() {
        let path = "\(reportDirectory)/\(self.getReportFileName())"
        let size = fileSize(path)
        if size > 0 {
            //delete the oldest file
            let deletePath = "\(directory)/\(self.getReportFileName())"
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: deletePath)
            } catch _ {
            }
        }
    }
    
    //MARK: -  Loggly Util Methods
    
    //the date formatter
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        if !logDateFormat.isEmpty && logDateFormat.length > 0 {
            formatter.dateFormat = logDateFormat
        } else {
            formatter.timeStyle = .medium
            formatter.dateStyle = .medium
        }
        return formatter
    }
    
    ///gets the log type with String
    // use colored Emojis for better visual distinction
    // of log level for Xcode 8
    func logTypeName(_ type: LogType, isEmojis:Bool) -> String {
        var logTypeStr = "";
        switch type {
        case .Info:
            logTypeStr = isEmojis ? "💙 Info - " : "Info - ";
            break;
        case .Verbose:
            logTypeStr = isEmojis ? "💜 Verbose - " : "Verbose - ";
            break;
        case .Warnings:
            logTypeStr = isEmojis ? "💛 Warnings - " : "Warnings - ";
            break;
        case .Debug:
            logTypeStr = isEmojis ? "💚 Debug - " : "Debug - ";
            break;
        case .Error:
            logTypeStr = isEmojis ? "❤️ Error - " : "Error - ";
            break;
        }
        
        return logTypeStr;
    }
    
    // Gets the log type with String
    func logJSONTypeName(_ type: LogType) -> String {
        var logTypeStr = "";
        switch type {
        case .Info:
            logTypeStr =  "Info"
            break;
        case .Verbose:
            logTypeStr = "Verbose" ;
            break;
        case .Warnings:
            logTypeStr = "Warnings" ;
            break;
        case .Debug:
            logTypeStr = "Debug"  ;
            break;
        case .Error:
            logTypeStr = "Error";
            break;
        }
        return logTypeStr;
    }
    
    /// Prints the log type with String and type color code.
    func printLog(_ type: LogType, text:String) {
        switch type {
        case .Info:
            ColorLog.blue(object: text)
            break;
        case .Verbose:
            ColorLog.purple(object: text)
            break;
        case .Warnings:
            ColorLog.yellow(object: text)
            break;
        case .Debug:
            ColorLog.green(object: text)
            break;
        case .Error:
            ColorLog.red(object: text)
            break;
        }
    }
    
    // Generate log text base on Log Format type.
    func getWriteTextBasedOnType(_ type: LogType, text: String, isDelimiter: Bool) -> String {
        let dateStr = dateFormatter.string(from: Date())
        if(logFormatType == LogFormatType.JSON) {
            let logJson = NSMutableDictionary();
            logJson.setValue(logJSONTypeName(type), forKey: "LogType")
            logJson.setValue(dateStr, forKey: "LogDate")
            logJson.setValue(text, forKey: "LogMessage")
            return "\(logJson.jsonString.replacingOccurrences(of: "\n", with: ""))\(isDelimiter ?"\n":"")"
        }
        return "[\(logTypeName(type, isEmojis: enableEmojis)) \(dateStr)]: \(text)\(isDelimiter ?"\n":"")"
    }
    
    ///write content to the current log file.
    open func write(_ type: LogType, text: String) {
        let path = "\(directory)/\(logName(0))"
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: path) {
            do {
                try "".write(toFile: path, atomically: true, encoding: logEncodingType)
            } catch  {
                print("error getting wriet string: \(error)")
            }
        }
        if let fileHandle = FileHandle(forWritingAtPath: path) {
            var writeText = getWriteTextBasedOnType(type, text: text, isDelimiter: true)
            fileHandle.seekToEndOfFile()
            fileHandle.write(writeText.data(using: logEncodingType)!)
            fileHandle.closeFile()
            writeText = getWriteTextBasedOnType(type, text: text, isDelimiter: false)
            #if os(iOS)
                print(writeText)
            #elseif os(OSX)
                printLog(type, text:writeText)
            #else
                printLog(type, text:writeText)
            #endif
            cleanup()
        }
        self.increaseLogCount(type);
    }
    
    ///do the checks and cleanup
    open func cleanup() {
        let path = "\(directory)/\(logName(0))"
        let size = fileSize(path)
        let maxSize: UInt64 = maxFileSize*1024
        if size > 0 && size >= maxSize && maxSize > 0 && maxFileCount > 0 {
            rename(0)
            //delete the oldest file
            let deletePath = "\(directory)/\(logName(maxFileCount))"
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(atPath: deletePath)
            } catch _ {
            }
        }
    }
    
    ///check the size of a file
    open func fileSize(_ path: String) -> UInt64 {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let attrs: NSDictionary? = try! fileManager.attributesOfItem(atPath: path) as NSDictionary?
            if let dict = attrs {
                return dict.fileSize()
            }
        }
        return 0
    }
    
    ///Recursive method call to rename log files
    func rename(_ index: Int) {
        let fileManager = FileManager.default
        let path = "\(directory)/\(logName(index))"
        let newPath = "\(directory)/\(logName(index+1))"
        if fileManager.fileExists(atPath: newPath) {
            rename(index+1)
        }
        do {
            try fileManager.moveItem(atPath: path, toPath: newPath)
        } catch _ {
        }
    }
    
    ///gets the log name
    func logName(_ num :Int) -> String {
        return "\(name)-\(num)\(getExtension())"
    }
    
    ///get the default log directory
    class func defaultReportDirectory() -> String {
        var path = ""
        let fileManager = FileManager.default
        #if os(iOS)
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            path = "\(paths[0])/Report"
        #elseif os(OSX)
            let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
            if let url = urls.last?.path {
                path = "\(url)/Report"
            }
        #endif
        if !fileManager.fileExists(atPath: path) && path != ""  {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
        }
        return path
    }
    
    ///get the default log directory
    class func defaultDirectory() -> String {
        var path = ""
        let fileManager = FileManager.default
        #if os(iOS)
            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
            path = "\(paths[0])/Logs"
        #elseif os(OSX)
            let urls = fileManager.urls(for: .libraryDirectory, in: .userDomainMask)
            if let url = urls.last?.path {
                path = "\(url)/Logs"
            }
        #endif
        if !fileManager.fileExists(atPath: path) && path != ""  {
            do {
                try fileManager.createDirectory(atPath: path, withIntermediateDirectories: false, attributes: nil)
            } catch _ {
            }
        }
        return path
    }
    
    //MARK: -  Loggly Util Methods
    
    ///a free function to make writing to the log with Log type
    open func getLogglyReportsOutput() -> NSDictionary {
        return Loggly.logger.getReportsOutput()
    }
    
    // Before logging details it return empty path. Once logging is done. Method return exact report path
    open func getLogglyReportCSVfilPath() -> String {
        return Loggly.logger.getReportsFilePath()
    }
    
    // Get the Loggly Info Count
    open func getLogCountBasedonType(_ type: LogType) -> NSInteger{
        return Loggly.logger.getCountBasedonLogType(type);
    }
    
    //MARK: -  Loggly Info Methods
    
    ///a free function to make writing to the log
    open func logglyInfo(text: String) {
        Loggly.logger.write(LogType.Info, text: text)
    }
    
    
    ///a free function to make writing to the log with Log type
    open func logglyInfo(dictionary: NSDictionary) {
        Loggly.logger.write(LogType.Info, text: dictionary.jsonString)
    }
    
    //MARK: -  Loggly Warning Methods
    ///a free function to make writing to the log
    open func logglyWarnings(text: String) {
        Loggly.logger.write(LogType.Warnings, text: text)
    }
    
    
    ///a free function to make writing to the log with Log type
    open func logglyWarnings(dictionary: NSDictionary) {
        Loggly.logger.write(LogType.Warnings, text: dictionary.jsonString)
    }
    
    //MARK: -  Loggly Verbose Methods
    ///a free function to make writing to the log
    open func logglyVerbose(text: String) {
        Loggly.logger.write(LogType.Debug, text: text)
    }
    
    ///a free function to make writing to the log with Log type
    open func logglyVerbose(dictionary: Dictionary<AnyHashable, Any>) {
        Loggly.logger.write(LogType.Debug, text: dictionary.jsonString)
    }
    
    //MARK: -  Loggly Debug Methods
    ///a free function to make writing to the log
    open func logglyDebug(text: String) {
        Loggly.logger.write(LogType.Debug, text: text)
    }
    
    
    ///a free function to make writing to the log with Log type
    open func logglyDebug(dictionary: NSDictionary) {
        Loggly.logger.write(LogType.Debug, text: dictionary.jsonString)
    }
    
    //MARK: -  Loggly Error Methods
    ///a free function to make writing to the log
    open func logglyError(text: String) {
        Loggly.logger.write(LogType.Error, text: text)
    }
    
    
    ///a free function to make writing to the log with Log type
    open func logglyError(dictionary: NSDictionary) {
        Loggly.logger.write(LogType.Error, text: dictionary.jsonString)
    }
    
    ///a free function to make writing to the log with Log type
    open func logglyError(error: NSError) {
        Loggly.logger.write(LogType.Error, text: error.localizedDescription)
    }
    
    
    //MARK: -  Loggly Methods with Log type
    
    ///a free function to make writing to the log with Log type
    open func loggly(_ type: LogType, text: String) {
        Loggly.logger.write(type, text: text)
    }
    
    ///a free function to make writing to the log with Log type
    open func loggly(_ type: LogType, dictionary: Dictionary<AnyHashable, Any>) {
        Loggly.logger.write(type, text: dictionary.jsonString)
    }
    
    ///a free function to make writing to the log with Log type
    open func loggly(_ type: LogType, dictionary: NSDictionary) {
        Loggly.logger.write(type, text: dictionary.jsonString)
    }
    
    
}

//MARK: -  Loggly Util Methods

///a free function to make writing to the log with Log type
public func getLogglyReportsOutput() -> NSDictionary {
    return Loggly.logger.getReportsOutput()
}

// Before logging details it return empty path. Once logging is done. Method return exact report path
public func getLogglyReportCSVfilPath() -> String {
    return Loggly.logger.getReportsFilePath()
}

// Get the Loggly Info Count
public func getLogCountBasedonType(_ type: LogType) -> NSInteger{
    return Loggly.logger.getCountBasedonLogType(type);
}

//MARK: -  Loggly Info Methods

///a free function to make writing to the log
public func logglyInfo(text: String) {
    Loggly.logger.write(LogType.Info, text: text)
}

///a free function to make writing to the log with Log type
public func logglyInfo(_ dictionary: Dictionary<AnyHashable, Any>) {
    Loggly.logger.write(LogType.Info, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func logglyInfo(_  dictionary: NSDictionary) {
    Loggly.logger.write(LogType.Info, text: dictionary.jsonString)
}

//MARK: -  Loggly Warning Methods
///a free function to make writing to the log
public func logglyWarnings(text: String) {
    Loggly.logger.write(LogType.Warnings, text: text)
}

///a free function to make writing to the log with Log type
public func logglyWarnings(_ dictionary: Dictionary<AnyHashable, Any>) {
    Loggly.logger.write(LogType.Warnings, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func logglyWarnings(_  dictionary: NSDictionary) {
    Loggly.logger.write(LogType.Warnings, text: dictionary.jsonString)
}

//MARK: -  Loggly Verbose Methods
///a free function to make writing to the log
public func logglyVerbose(text: String) {
    Loggly.logger.write(LogType.Debug, text: text)
}

///a free function to make writing to the log with Log type
public func logglyVerbose(_ dictionary: Dictionary<AnyHashable, Any>) {
    Loggly.logger.write(LogType.Debug, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func logglyVerbose(_  dictionary: NSDictionary) {
    Loggly.logger.write(LogType.Debug, text: dictionary.jsonString)
}

//MARK: -  Loggly Debug Methods
///a free function to make writing to the log
public func logglyDebug(text: String) {
    Loggly.logger.write(LogType.Debug, text: text)
}

///a free function to make writing to the log with Log type
public func logglyDebug(_ dictionary: Dictionary<AnyHashable, Any>) {
    Loggly.logger.write(LogType.Debug, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func logglyDebug(_  dictionary: NSDictionary) {
    Loggly.logger.write(LogType.Debug, text: dictionary.jsonString)
}

//MARK: -  Loggly Error Methods
///a free function to make writing to the log
public func logglyError(text: String) {
    Loggly.logger.write(LogType.Error, text: text)
}

///a free function to make writing to the log with Log type
public func logglyError(_ dictionary: Dictionary<AnyHashable, Any>) {
    Loggly.logger.write(LogType.Error, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func logglyError(_  dictionary: NSDictionary) {
    Loggly.logger.write(LogType.Error, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func logglyError(_  error: NSError) {
    Loggly.logger.write(LogType.Error, text: error.localizedDescription)
}

///a free function to make writing to the log with Log type
public func logglyError(_  error: Error) {
    Loggly.logger.write(LogType.Error, text: error.localizedDescription)
}


//MARK: -  Loggly Methods with Log type

///a free function to make writing to the log with Log type
public func loggly(_ type: LogType, text: String) {
    Loggly.logger.write(type, text: text)
}

///a free function to make writing to the log with Log type
public func loggly(_ type: LogType, dictionary: Dictionary<AnyHashable, Any>) {
    Loggly.logger.write(type, text: dictionary.jsonString)
}

///a free function to make writing to the log with Log type
public func loggly(_ type: LogType, dictionary: NSDictionary) {
    Loggly.logger.write(type, text: dictionary.jsonString)
}

