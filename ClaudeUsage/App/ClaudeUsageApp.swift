import SwiftUI

@main
struct ClaudeUsageApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Empty settings window - we don't need one for a menu bar app
        Settings {
            EmptyView()
        }
    }
}
