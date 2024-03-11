// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let swiftSettings: Array<SwiftSetting> = [
    .enableUpcomingFeature("ConciseMagicFile"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("BareSlashRegexLiterals"),
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("AccessLevelOnImport"),
    .enableExperimentalFeature("StrictConcurrency"),
//    .enableExperimentalFeature("VariadicGenerics"),
]

let package = Package(
    name: "semver",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .macCatalyst(.v13),
    ],
    products: [
        .library(
            name: "SemVer",
            targets: ["SemVer"]),
        .library(
            name: "SemVerMacros",
            targets: ["SemVerMacros"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-syntax", from: "509.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SemVerParsing",
            swiftSettings: swiftSettings),
        .macro(
            name: "SemVerMacrosPlugin",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                "SemVerParsing",
            ],
            swiftSettings: swiftSettings),
        .target(
            name: "SemVer",
            dependencies: ["SemVerParsing"],
            swiftSettings: swiftSettings),
        .target(
            name: "SemVerMacros",
            dependencies: [
                "SemVer",
                "SemVerMacrosPlugin",
            ],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "SemVerParsingTests",
            dependencies: ["SemVerParsing"],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "SemVerTests",
            dependencies: [
                "SemVerParsing",
                "SemVer",
                "SemVerMacros",
            ],
            swiftSettings: swiftSettings),
        .testTarget(
            name: "SemVerMacrosPluginTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "SemVerParsing", // Xcode fails otherwise...
                "SemVerMacrosPlugin",
            ],
            swiftSettings: swiftSettings),
    ]
)
