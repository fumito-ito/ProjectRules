// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ProjectRulesGenerator",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "ProjectRules", targets: ["ProjectRulesCLI"]),
        .executable(name: "ProjectRulesIO", targets: ["ProjectRulesIO"]),
        .library(name: "ProjectRulesGenerator", targets: ["ProjectRulesGenerator"])
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "ProjectRulesGenerator",
            dependencies: []
        ),
        .executableTarget(
            name: "ProjectRulesIO",
            dependencies: [
                "ProjectRulesGenerator",
                .product(name: "Vapor", package: "vapor")
            ]
        ),
        .executableTarget(
            name: "ProjectRulesCLI",
            dependencies: [
                "ProjectRulesGenerator",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
