// swift-tools-version:5.10

import class Foundation.ProcessInfo
import PackageDescription


#if swift(<6)
let swiftConcurrency: SwiftSetting = .enableExperimentalFeature("StrictConcurrency")
#else
let swiftConcurrency: SwiftSetting = .enableUpcomingFeature("StrictConcurrency")
#endif


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
    dependencies: [] + swiftLintPackage(),
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
            ],
            swiftSettings: [
                swiftConcurrency
            ],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}


func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
