import AppKit
import PostureCore
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    // Shared model objects — held here so they outlive the App struct
    let settings = SettingsStore()
    let motionManager = HeadphoneMotionManager()
    let diagnostics = DiagnosticsStore()
    let dailyStats = DailyStatsStore()
    let postureAnalyzer = PostureAnalyzer()
    let notificationManager = NotificationManager()
    var menuBarManager: MenuBarManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide from Dock — pure menu bar app
        NSApp.setActivationPolicy(.accessory)
        markLaunchStarted()
        diagnostics.recordLaunch(enabled: settings.localDiagnosticsEnabled)
        Task { await notificationManager.refreshAuthorizationStatus() }

        // Wire motion → analyzer
        motionManager.onMotionUpdate = { [weak self] sample in
            guard let self else { return }
            self.postureAnalyzer.update(sample: sample, settings: self.settings.postureSettings)
        }

        // Wire AirPods connect/disconnect → analyzer device state
        motionManager.onAvailabilityChanged = { [weak self] availability in
            guard let self else { return }
            if availability == .connected {
                self.postureAnalyzer.setSource(.airPods, calibration: self.postureAnalyzer.calibrationProfile)
            } else {
                self.postureAnalyzer.resetForUnavailable(keeping: self.postureAnalyzer.calibrationProfile)
                self.diagnostics.recordDisconnect(enabled: self.settings.localDiagnosticsEnabled)
            }
            self.menuBarManager?.updateIcon(state: self.postureAnalyzer.state, availability: availability)
            if availability == .connected, self.settings.autoStart {
                self.motionManager.startMonitoring()
            }
        }

        motionManager.onError = { [weak self] _ in
            guard let self else { return }
            self.menuBarManager?.updateIcon(state: self.postureAnalyzer.state, availability: self.motionManager.availabilityState)
        }

        // Wire bad posture → notification
        postureAnalyzer.onBadPosture = { [weak self] in
            guard let self else { return }
            self.notificationManager.sendPostureAlert(cooldownMinutes: self.settings.cooldownMinutes)
            self.diagnostics.recordNotificationSent(enabled: self.settings.localDiagnosticsEnabled)
        }

        // Wire state changes → menu bar icon + daily stats
        postureAnalyzer.onStateChange = { [weak self] state in
            guard let self else { return }
            self.menuBarManager?.updateIcon(state: state, availability: self.motionManager.availabilityState)
            self.dailyStats.recordState(state)
        }

        // Wire snooze → pause monitoring
        notificationManager.onSnooze = { [weak self] duration in
            self?.motionManager.pauseMonitoring(for: duration)
        }

        // Periodically update daily stats time counters
        Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self else { return }
                self.dailyStats.tick(currentState: self.postureAnalyzer.state)
            }
        }

        // Build the menu bar item (after all wiring is done)
        menuBarManager = MenuBarManager(
            postureAnalyzer: postureAnalyzer,
            motionManager: motionManager,
            settings: settings,
            notificationManager: notificationManager,
            diagnostics: diagnostics,
            dailyStats: dailyStats
        )

        // Request notification permission asynchronously
        Task {
            await notificationManager.requestAuthorization()
        }

        // Start listening for AirPods + motion data
        motionManager.setup()
        if settings.autoStart, motionManager.isConnected {
            motionManager.startMonitoring()
        }
        menuBarManager?.updateIcon(state: postureAnalyzer.state, availability: motionManager.availabilityState)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Keep running when Settings window is closed — it's a menu bar app
        return false
    }

    func applicationWillTerminate(_ notification: Notification) {
        UserDefaults.standard.set(true, forKey: "app.cleanExit")
        AppLogger.lifecycle.info("Application terminating cleanly")
    }

    private func markLaunchStarted() {
        let cleanExitKey = "app.cleanExit"
        let previousEndedCleanly = UserDefaults.standard.object(forKey: cleanExitKey) as? Bool ?? true
        if !previousEndedCleanly {
            diagnostics.recordUnexpectedTermination(enabled: settings.localDiagnosticsEnabled)
            AppLogger.lifecycle.error("Previous launch ended unexpectedly")
        }
        UserDefaults.standard.set(false, forKey: cleanExitKey)
        AppLogger.lifecycle.info("Application launch completed")
    }
}
