// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TOMLDeserializer",
    products: [
        .library(
            name: "TOMLDeserializer",
            targets: ["TOMLDeserializer"])
    ],
    dependencies: [
        .package(url: "https://github.com/dduan/NetTime", from: "0.2.3")
    ],
    targets: [
        .target(
            name: "TOMLDeserializer",
            dependencies: ["NetTime"]),
        .testTarget(
            name: "TOMLDeserializerTests",
            dependencies: ["TOMLDeserializer", "NetTime"],
            exclude: [
                "Tests/DrStringTests/invalid_fixtures",
                "Tests/DrStringTests/valid_fixtures",
            ]),
    ]
)
