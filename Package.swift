// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Kanna",
    products: [
      .library(name: "Kanna", targets: ["Kanna"]),
    ],
    targets: [
        .systemLibrary(
            name: "libxml2",
            path: "Modules",
            pkgConfig: "libxml-2.0",
            providers: [
                .apt(["libxml2-dev"]),
                .brew(["libxml2"]),
            ]
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
