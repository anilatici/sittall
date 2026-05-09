// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "SitTall",
    defaultLocalization: "en",
    platforms: [.macOS(.v14)],
    products: [
        .library(
            name: "PostureCore",
            targets: ["PostureCore"]
        )
    ],
    targets: [
        .target(
            name: "PostureCore",
            path: "Shared/PostureCore"
        ),
        .executableTarget(
            name: "SitTall",
            dependencies: ["PostureCore"],
            path: "Sources/SitTall",
            resources: [.process("Resources"), .process("Assets.xcassets")]
        ),
        .testTarget(
            name: "PostureCoreTests",
            dependencies: ["PostureCore"],
            path: "Tests/PostureCoreTests"
        )
    ]
)
