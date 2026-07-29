// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "PotatoBuddy",
    platforms: [.macOS(.v12)],
    targets: [
        .executableTarget(
            name: "PotatoBuddy",
            path: "Sources/PotatoBuddy"
        )
    ]
)
