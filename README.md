# SwiftLoggly
Simple way to logging with rich feature framework in Swift.

## Features

- Method can helps to log String, NSDictionary, Dictionary.

First thing is to import the framework. See the Installation instructions on how to add the framework to your project.

```swift
//iOS
import SwiftLoggly

//macOS
import SwiftLogglyOSX

```

## Example

SwiftLoggly can be used right out of the box with no configuration, simply call the logging function.

```swift

// String
loggly("Welcome to SwiftLoggly!")

// NSDictionary
loggly(nsDictionary)

// Dictionary
loggly(dictionary)

```

That will create a log file in the proper directory on both OS X and iOS.

OS X log files will be created in the OS X log directory (found under: /Library/Logs). The iOS log files will be created in your apps document directory under a folder called Logs.

## Configuration

There are a few configurable options in SwiftLog.

```swift
//This writes to the log
loggly("write to the log!")

//Set the name of the log files
Loggly.logger.name = "Sample" //default is "logglyfile"

//Set the max size of each log file. Value is in KB
Loggly.logger.maxFileSize = 2048 //default is 1024

//Set the max number of logs files that will be kept
Loggly.logger.maxFileCount = 8 //default is 4

//Set the directory in which the logs files will be written
Loggly.logger.directory = "/Library/XXX-folder-name-XXX" //default is the standard logging directory for each platform.

```

## Installation

### CocoaPods

Check out [Get Started](http://cocoapods.org/) tab on [cocoapods.org](http://cocoapods.org/).

To use SwiftLoggly in your project add the following 'Podfile' to your project

	source 'https://github.com/CocoaPods/Specs.git'
	platform :ios, '8.0'
	use_frameworks!

	pod 'SwiftLoggly'

Then run:

    pod install


## License

SwiftLoggly is licensed under the MIT License.

## Contact

### Dalton Cherry
* http://vigneshuvi.github.io