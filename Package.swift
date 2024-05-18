// swift-tools-version:5.10
import PackageDescription


let package = Package(
    name: "ResearchKit",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "ResearchKit", targets: ["ResearchKit"]),
        .library(name: "ResearchKitUI", targets: ["ResearchKitUI"]),
        .library(name: "ResearchKitActiveTask", targets: ["ResearchKitActiveTask"]),
        .library(name: "ResearchKitSwiftUI", targets: ["ResearchKitSwiftUI"])
    ],
    targets: [
        .binaryTarget(
            name: "ResearchKit",
            path: "./Sources/ResearchKit.xcframework"
        ),
        .binaryTarget(
            name: "ResearchKitUI",
            path: "./Sources/ResearchKitUI.xcframework"
        ),
        .binaryTarget(
            name: "ResearchKitActiveTask",
            path: "./Sources/ResearchKitActiveTask.xcframework"
        ),
        .target(
            name: "ResearchKitSwiftUI",
            dependencies: [
                .target(name: "ResearchKit"),
                .target(name: "ResearchKitUI"),
                .target(name: "ResearchKitActiveTask", condition: .when(platforms: [.iOS]))
            ]
        )
    ]
)
