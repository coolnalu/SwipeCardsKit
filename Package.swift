// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwipeCardsKit",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SwipeCardsKit",
            targets: ["SwipeCardsKit"]
        ),
    ],
    targets: [
        .target(
            name: "SwipeCardsKit"
        ),
    ]
)
