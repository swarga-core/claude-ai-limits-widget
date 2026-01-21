// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ClaudeUsage",
    platforms: [
        .macOS(.v15)
    ],
    targets: [
        .executableTarget(
            name: "ClaudeUsage",
            path: "ClaudeUsage",
            sources: [
                "App/ClaudeUsageApp.swift",
                "App/AppDelegate.swift",
                "Core/UsageModels.swift",
                "Core/KeychainHelper.swift",
                "Core/UsageService.swift",
                "Features/MenuBar/StatusBarController.swift",
                "Features/MenuBar/UsagePopoverView.swift"
            ],
            resources: [
                .process("Resources/Assets.xcassets")
            ]
        )
    ]
)
