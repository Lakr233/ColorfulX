// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ColorfulX",
    platforms: [
        .iOS(.v13),
        .macOS(.v11),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "ColorfulX", targets: ["ColorfulX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/ColorVector.git", from: "1.0.4"),
        .package(url: "https://github.com/Lakr233/SpringInterpolation.git", from: "1.3.1"),
        .package(url: "https://github.com/Lakr233/MSDisplayLink.git", from: "2.0.8"),
    ],
    targets: [
        .target(
            name: "ColorfulX",
            dependencies: [
                "ColorVector",
                "SpringInterpolation",
                "MSDisplayLink",
            ]
        ),
    ]
)
