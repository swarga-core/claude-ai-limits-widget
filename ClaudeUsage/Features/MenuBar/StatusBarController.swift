import AppKit
import SwiftUI
import Combine

@MainActor
final class StatusBarController {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var cancellables = Set<AnyCancellable>()

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        popover = NSPopover()
        popover.contentSize = NSSize(width: 280, height: 368)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(rootView: UsagePopoverView())

        setupStatusButton()
        observeUsageChanges()
    }

    private func setupStatusButton() {
        if let button = statusItem.button {
            // Set up SF Symbol icon
            if let icon = NSImage(systemSymbolName: "sun.max", accessibilityDescription: "Claude Usage") {
                icon.isTemplate = true
                button.image = icon
                button.imagePosition = .imageLeft
            }
            button.title = " --"
            button.action = #selector(togglePopover)
            button.target = self

            statusItem.menu = nil // We'll handle clicks manually
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    private func observeUsageChanges() {
        UsageService.shared.$usageResponse
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateMenuBarTitle()
            }
            .store(in: &cancellables)
    }

    private func updateMenuBarTitle() {
        if let button = statusItem.button {
            button.title = " " + UsageService.shared.menuBarTitle
        }
    }

    @objc private func togglePopover(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent

        if event?.type == .rightMouseUp {
            showContextMenu()
        } else {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                if let button = statusItem.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    popover.contentViewController?.view.window?.makeKey()
                }
            }
        }
    }

    private func showContextMenu() {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: "r"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit Claude Usage", action: #selector(quit), keyEquivalent: "q"))

        for item in menu.items {
            item.target = self
        }

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func refresh() {
        Task {
            await UsageService.shared.fetchUsage()
        }
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
