//
//  UviUtils.swift
//  SwiftLoggly
//
//  Created by qbuser on 19/05/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.
//

//MARK: -  Extension for String to find length
extension String {
    var length: Int {
        return self.characters.count
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

@objc open class UviUtils :NSObject {
    
    ///gets the log type with String
    // use colored Emojis for better visual distinction
    // of log level for Xcode 8
    class func logTypeName(_ type: LogType, isEmojis:Bool) -> String {
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
   class func logJSONTypeName(_ type: LogType) -> String {
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
    class func printLog(_ type: LogType, text:String) {
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
    
    
    ///check the size of a file
    @objc class func fileSize(_ path: String) -> UInt64 {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            let attrs: NSDictionary? = try! fileManager.attributesOfItem(atPath: path) as NSDictionary?
            if let dict = attrs {
                return dict.fileSize()
            }
        }
        return 0
    }
    
    ///gets the log name
    class func logName(_ name: String, prefix num :Int) -> String {
        return "\(name)-\(num).log"
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

