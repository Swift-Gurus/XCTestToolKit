// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XCTestToolKit",
    platforms: [.iOS(.v14), .macOS(.v10_15)],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "XCTestToolKit",
            targets: ["XCTestToolKit"]

        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-numerics", branch: "main")
    ],

    targets: [
        .target(
            name: "XCTestToolKit",
            linkerSettings: [.linkedFramework("XCTest")]
        ),
        .testTarget(
            name: "XCTestToolKitTests",
            dependencies: ["XCTestToolKit",
                           .product(name: "Numerics", package: "swift-numerics")
            ],
            linkerSettings: [.linkedFramework("XCTest")]
        )

    ]

)
