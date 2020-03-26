// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

#if swift(>=5.2) && !os(Linux)
let pkgConfig: String? = nil
#else
let pkgConfig = "libxml-2.0"
#endif

#if swift(>=5.2)
let provider: [SystemPackageProvider] = [
    .apt(["libxml2-dev"]),
]
#else
let provider: [SystemPackageProvider] = [
    .apt(["libxml2-dev"]),
    .brew(["libxml2"]),
]
#endif

let package = Package(
    name: "Kanna",
    products: [
      .library(name: "Kanna", targets: ["Kanna"]),
    ],
    targets: [
        .systemLibrary(
            name: "libxml2",
            path: "Modules",
            pkgConfig: pkgConfig,
            providers: provider
        ),
        .target(
            name: "Kanna",
            dependencies: ["libxml2"],
            path: "Sources",
            exclude: [
                "Sources/Info.plist",
                "Sources/Kanna.h",
                "Tests/KannaTests/Data"
            ]
        ),
        .testTarget(
            name: "KannaTests",
            dependencies: ["Kanna"]
        )
    ],
    swiftLanguageVersions: [.v5]
)
