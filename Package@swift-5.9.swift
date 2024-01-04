// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ColorfulX",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "ColorfulX", targets: ["ColorfulX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lakr233/SpringInterpolation.git", from: "1.1.2"),
    ],
    targets: [
        .target(
            name: "ColorfulX",
            dependencies: ["SpringInterpolation"],
            resources: [
                .process("Shaders/MulticolorGradientShader.metal"),
            ]
        ),
    ]
)
