// swift-tools-version:5.9
import PackageDescription


let package = Package(
    name: "ResearchKit",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(name: "ResearchKit", targets: ["ResearchKit"]),
        .library(name: "ResearchKitSwiftUI", targets: ["ResearchKitSwiftUI"])
    ],
    targets: [
        .binaryTarget(
            name: "ResearchKit",
            path: "./ResearchKit.xcframework"
        ),
        .target(
            name: "ResearchKitSwiftUI",
            dependencies: [
                .target(name: "ResearchKit")
            ]
        )
    ]
)
