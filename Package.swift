// swift-tools-version: 6.0

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
    .library(name: "ColorfulX", targets: ["ColorfulX"])
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
      ],
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ],
    )
  ],
)
