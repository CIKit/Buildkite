// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Buildkite",
    products: [
        .library(name: "Buildkite", targets: ["API", "Domain"])
    ],
    dependencies: [
        .package(url: "https://github.com/antitypical/Result", from: "4.1.0"),
        .package(url: "https://github.com/ProcedureKit/ProcedureKit", .branch("development"))
    ],
    targets: [
        .target(name: "Utilities"),
        .target(name: "Domain", dependencies: ["Utilities", "ProcedureKit"]),
        .target(
            name: "API",
            dependencies: ["Domain", "Utilities", "ProcedureKit", "ProcedureKitNetwork", "Result"]),
        .testTarget(
            name: "APITests",
            dependencies: ["API", "ProcedureKit", "ProcedureKitNetwork", "TestingProcedureKit"]),
        .testTarget(
            name: "DomainTests",
            dependencies: ["Domain"]),
        .testTarget(
            name: "UtilitiesTests",
            dependencies: ["Utilities"])
        ]
)

