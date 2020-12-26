// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "TOMLDeserializer",
    products: [
        .library(
            name: "TOMLDeserializer",
            targets: ["TOMLDeserializer"])
    ],
    targets: [
        .target(name: "TOMLDeserializer"),
        .testTarget(
            name: "TOMLDeserializerTests",
            dependencies: ["TOMLDeserializer"],
            exclude: [
                "Tests/DrStringTests/invalid_fixtures",
                "Tests/DrStringTests/valid_fixtures",
            ]),
    ]
)
