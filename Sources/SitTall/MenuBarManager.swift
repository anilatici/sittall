import AppKit
import PostureCore
import SwiftUI

@MainActor
final class MenuBarManager {
    private var statusItem: NSStatusItem
    private let popover = NSPopover()
    private let postureAnalyzer: PostureAnalyzer
    private let motionManager: HeadphoneMotionManager
    private let settings: SettingsStore
    private let notificationManager: NotificationManager
    private let diagnostics: DiagnosticsStore
    private let dailyStats: DailyStatsStore

    init(
        postureAnalyzer: PostureAnalyzer,
        motionManager: HeadphoneMotionManager,
        settings: SettingsStore,
        notificationManager: NotificationManager,
        diagnostics: DiagnosticsStore,
        dailyStats: DailyStatsStore
    ) {
        self.postureAnalyzer = postureAnalyzer
        self.motionManager = motionManager
        self.settings = settings
        self.notificationManager = notificationManager
        self.diagnostics = diagnostics
        self.dailyStats = dailyStats

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        let contentView = MenuContentView()
            .environmentObject(postureAnalyzer)
            .environmentObject(motionManager)
            .environmentObject(settings)
            .environmentObject(notificationManager)
            .environmentObject(diagnostics)
            .environmentObject(dailyStats)
        let hostingVC = NSHostingController(rootView: contentView)
        popover.contentViewController = hostingVC
        popover.contentSize = NSSize(width: 300, height: 520)
        popover.behavior = .transient

        if let button = statusItem.button {
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(handleButtonClick(_:))
            button.target = self
            button.toolTip = String(localized: "SitTall - Fix Your Posture", bundle: Bundle.sitTallResources)
        }

        updateIcon(state: postureAnalyzer.state, availability: motionManager.availabilityState)
    }

    func updateIcon(state: PostureState, availability: MotionAvailabilityState) {
        guard let button = statusItem.button else { return }
        let effectiveState: PostureState = availability == .connected ? state : .unavailable

        let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
            .applying(NSImage.SymbolConfiguration(paletteColors: [effectiveState.color]))

        if let image = NSImage(
            systemSymbolName: effectiveState.symbolName,
            accessibilityDescription: effectiveState.statusDescription
        )?.withSymbolConfiguration(config) {
            button.image = image
            button.title = ""
        } else {
            // Fallback so the button is never invisible
            button.image = nil
            button.title = "P"
        }
        button.toolTip = availability == .connected
            ? effectiveState.statusDescription
            : availability.statusDescription
    }

    @objc private func handleButtonClick(_ sender: NSStatusBarButton) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            popover.show(
                relativeTo: sender.bounds,
                of: sender,
                preferredEdge: .minY
            )
            // Needed so the popover gets keyboard focus
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
