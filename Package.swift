// swift-tools-version:4.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Kanna",
    products: [
      .library(name: "Kanna", targets: ["Kanna"]),
    ],
    dependencies: [
        .package(url: "https://github.com/tid-kijyun/SwiftClibxml2.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "Kanna",
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
