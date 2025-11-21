// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "Features",
            targets: ["Features"]
        )
    ],
    dependencies: [
        .package(path: "../Core"),
        .package(path: "../CommonUI")
    ],
    targets: [
        .target(
            name: "Features",
            dependencies: [
                "Core",
                "CommonUI"
            ],
            path: "Sources/Features"
        ),
        .testTarget(
            name: "FeaturesTests",
            dependencies: ["Features"],
            path: "Tests/FeaturesTests"
        )
    ]
)
