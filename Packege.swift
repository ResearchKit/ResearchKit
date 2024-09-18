// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "ResearchKit",
    platforms: [
        .iOS(.v13)  // Ajuste a versão mínima do iOS conforme necessário
    ],
    products: [
        .library(
            name: "ResearchKit",
            targets: ["ResearchKit"]),
    ],
    targets: [
        .target(
            name: "ResearchKit",
            path: "ResearchKit", // Diretório onde o código principal está localizado
            exclude: ["ResearchKit.xcodeproj", "README.md", "LICENSE"]), // Excluir arquivos que não são necessários no pacote
        .testTarget(
            name: "ResearchKitTests",
            dependencies: ["ResearchKit"],
            path: "ResearchKitTests"),
    ]
)
