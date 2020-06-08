// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Sandbox",
    platforms: [
        .macOS(.v10_10),
    ],
    products: [
        .library(
            name: "Sandbox",
            targets: [
                "Sandbox",
            ]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Sandbox",
            dependencies: [
            ]
        ),
        .testTarget(
            name: "SandboxTests",
            dependencies: [
                "Sandbox",
            ]
        ),
    ]
)
