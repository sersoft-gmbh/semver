// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "semver",
    products: [
        .library(name: "SemVer", targets: ["SemVer"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(name: "SemVer"),
        .testTarget(
            name: "SemVerTests",
            dependencies: ["SemVer"]),
    ]
)
