// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OpenCloudData",
    platforms: [
        .iOS("18.4")
    ],
    products: [
        .library(
            name: "OpenCloudData",
            targets: ["OpenCloudData"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/pookjw/ellekit", branch: "main")
    ],
    targets: [
        .target(
            name: "OpenCloudData",
            dependencies: [
                .product(name: "ellekit", package: "ellekit")
            ],
            publicHeadersPath: "Public",
            cSettings: [
              .headerSearchPath("../"),
              .unsafeFlags(["-fobjc-weak", "-fno-objc-arc"])
            ],
            linkerSettings: [
              .linkedFramework("CoreData"),
              .linkedFramework("CloudKit")
            ]
        ),
        .testTarget(
            name: "OpenCloudDataTests",
            dependencies: ["OpenCloudData"],
            cSettings: [
                .headerSearchPath("../../Sources"),
                .unsafeFlags(["-fobjc-weak", "-fno-objc-arc"])
            ]
        )
    ]
)
