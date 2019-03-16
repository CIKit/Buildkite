// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Buildkite",
    products: [
        .library(name: "Buildkite", targets: ["Buildkite"])
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result", from: "4.1.0"),
        .package(url: "https://github.com/ProcedureKit/ProcedureKit", .branch("development"))
    ],
    targets: [
        .target(
            name: "Buildkite",
            dependencies: ["ProcedureKit", "ProcedureKitNetwork", "Result"]),
        .testTarget(
            name: "BuildkiteTests",
            dependencies: ["Buildkite", "TestingProcedureKit"]),
        ]
)

