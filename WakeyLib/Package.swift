// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WakeyLib",
    platforms: [
        .iOS(.v17),
        .tvOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WakeyLib",
            targets: ["WakeyLib"]
        ),
    ],
    targets: [
        .target(
            name: "WakeyLib"
        ),
        .testTarget(
            name: "WakeyLibTests",
            dependencies: ["WakeyLib"],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
