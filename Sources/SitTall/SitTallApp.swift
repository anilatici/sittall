import SwiftUI

@main
struct SitTallApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // The Settings scene gives us a proper settings window accessible
        // via Cmd-comma and the "Settings…" button in the popover.
        Settings {
            SettingsView()
                .environmentObject(appDelegate.settings)
                .environmentObject(appDelegate.postureAnalyzer)
                .environmentObject(appDelegate.motionManager)
                .environmentObject(appDelegate.notificationManager)
                .environmentObject(appDelegate.diagnostics)
                .environmentObject(appDelegate.dailyStats)
        }
    }
}
