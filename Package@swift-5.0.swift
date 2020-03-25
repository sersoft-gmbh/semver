// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "SemVer",
    products: [
        .library(name: "SemVer", targets: ["SemVer"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "SemVer",
            exclude: ["Supporting Files"]),
        .testTarget(
            name: "SemVerTests",
            dependencies: ["SemVer"],
            exclude: ["Supporting Files"]),
    ]
)
