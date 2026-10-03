// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ColorfulX",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .macCatalyst(.v15),
        .tvOS(.v15),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "ColorfulX", targets: ["ColorfulX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/ColorVector.git", from: "1.0.5"),
        .package(url: "https://github.com/Lakr233/SpringInterpolation.git", from: "3.0.1"),
        .package(url: "https://github.com/Lakr233/DisplayLink.git", from: "3.0.1"),
    ],
    targets: [
        .target(
            name: "ColorfulX",
            dependencies: [
                "ColorVector",
                "SpringInterpolation",
                "DisplayLink",
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6),
            ],
        ),
    ],
)
