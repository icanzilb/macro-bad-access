// swift-tools-version: 5.9
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Debounce",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [
        .library(
            name: "Debounce",
            targets: ["Debounce"]
        ),
        .executable(
            name: "DebounceClient",
            targets: ["DebounceClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "DebounceMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),

        .target(name: "Debounce", dependencies: ["DebounceMacros"]),

        .executableTarget(name: "DebounceClient", dependencies: ["Debounce"]),

        .testTarget(
            name: "DebounceTests",
            dependencies: [
                "DebounceMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
