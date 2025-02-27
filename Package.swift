// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "NFTDenemesi",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "NFTDenemesi",
            targets: ["NFTDenemesi"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.8.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.10.2")
    ],
    targets: [
        .target(
            name: "NFTDenemesi",
            dependencies: [
                "Alamofire",
                "Kingfisher"
            ]),
        .testTarget(
            name: "NFTDenemesiTests",
            dependencies: ["NFTDenemesi"]),
    ]
) 