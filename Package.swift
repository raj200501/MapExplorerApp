// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MapExplorerApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "MapExplorerCore", targets: ["MapExplorerCore"]),
        .executable(name: "map-explorer", targets: ["MapExplorerCLI"])
    ],
    targets: [
        .target(
            name: "MapExplorerCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "MapExplorerCLI",
            dependencies: ["MapExplorerCore"]
        ),
        .testTarget(
            name: "MapExplorerCoreTests",
            dependencies: ["MapExplorerCore"]
        )
    ]
)
