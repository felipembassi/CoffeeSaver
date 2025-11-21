// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CommonUI",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "CommonUI",
            targets: ["CommonUI"]
        )
    ],
    targets: [
        .target(
            name: "CommonUI",
            dependencies: [],
            path: "Sources/CommonUI",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CommonUITests",
            dependencies: ["CommonUI"],
            path: "Tests/CommonUITests"
        )
    ]
)
