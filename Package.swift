// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ETCarouSwift",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "ETCarouSwift",
            targets: ["ETCarouSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        .target(
            name: "ETCarouSwift",
            dependencies: [],
            path: "ETCarouSwift"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
