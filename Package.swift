// swift-tools-version:5.5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
//  Created by Vignesh on 30/01/17.
//  Copyright © 2017 vigneshuvi. All rights reserved.

import PackageDescription

let package = Package(
    name: "SwiftLoggly",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SwiftLoggly",
            targets: ["SwiftLoggly"]),
        
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SwiftLoggly",
            dependencies: [],
            path: "Sources"),
    ]
)
