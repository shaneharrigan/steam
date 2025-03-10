// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "steam",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "steam",
            targets: ["steam"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "18.7.5")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "steam"),
        .testTarget(
            name: "steamTests",
            dependencies: ["steam"]
        ),
    ]
)
