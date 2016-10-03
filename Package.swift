import PackageDescription

let package = Package(
    name: "Kanna",
    dependencies: [
		.Package(url: "../Kanna", majorVersion: 1)
    ]
)

