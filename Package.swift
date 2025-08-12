// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacVisionOCR",
    platforms: [.macOS(.v10_15)],
    products: [
        .library(
            name: "MacVisionOCRNodeJS",
            type: .dynamic,
            targets: ["MacVisionOCRNodeJS"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/kabiroberai/node-swift.git", from: "1.4.0")
    ],
    targets: [
        .target(
            name: "MacVisionOCRCore",
            dependencies: []
        ),
        .target(
            name: "MacVisionOCRNodeJS",
            dependencies: [
                "MacVisionOCRCore",
                .product(name: "NodeAPI", package: "node-swift"),
                .product(name: "NodeModuleSupport", package: "node-swift"),
            ]
        ),
    ]
)
