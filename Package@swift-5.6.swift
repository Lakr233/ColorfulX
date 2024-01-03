// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ColorfulX",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
        .tvOS(.v14),
    ],
    products: [
        .library(name: "ColorfulX", targets: ["ColorfulX"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Lessica/SpringInterpolation.git", branch: "ci/add-platforms"),
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
