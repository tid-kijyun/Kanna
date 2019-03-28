// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Kanna",
    products: [
      .library(name: "Kanna", targets: ["Kanna"]),
    ],
    targets: [
        .systemLibrary(
                name: "libxmlKanna",
                path: "Modules",
                pkgConfig: "libxml-2.0",
                providers: [
                    .brew(["libxml2"]),
                    .apt(["libxml2-dev"])
                ]),
        .target(name: "Kanna",
                dependencies: ["libxmlKanna"],
                path: "Sources",
                exclude: [
                    "Sources/Info.plist",
                    "Sources/Kanna.h",
                    "Tests/KannaTests/Data"
                ]),
        .testTarget(name: "KannaTests",
                    dependencies: ["Kanna"]
                )
    ]
)
