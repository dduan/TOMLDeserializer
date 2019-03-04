// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "TOMLDeserializer",
    products: [
        .library(
            name: "TOMLDeserializer",
            targets: ["TOMLDeserializer"])
    ],
    dependencies: [
        .package(url: "https://github.com/dduan/NetTime", from: "0.1.0")
    ],
    targets: [
        .target(
            name: "TOMLDeserializer",
            dependencies: ["NetTime"]),
        .testTarget(
            name: "TOMLDeserializerTests",
            dependencies: ["TOMLDeserializer", "NetTime"]),
    ]
)
