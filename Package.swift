import PackageDescription

let package = Package(
    name: "Kanna",
    dependencies: [
        .Package(url: "https://github.com/tid-kijyun/SwiftClibxml2.git", majorVersion: 1)
    ],
    exclude: [
        "Sources/Info.plist",
        "Sources/Kanna.h",
        "Tests/KannaTests/Data"
    ]
)

