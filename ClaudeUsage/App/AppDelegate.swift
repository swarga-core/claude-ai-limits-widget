import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon - this is a menu bar only app
        NSApp.setActivationPolicy(.accessory)

        // Initialize the status bar controller
        statusBarController = StatusBarController()

        // Start auto-refresh (every 1 minute)
        UsageService.shared.startAutoRefresh(interval: 60)
    }

    func applicationWillTerminate(_ notification: Notification) {
        UsageService.shared.stopAutoRefresh()
    }
}
