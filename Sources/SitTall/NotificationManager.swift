import Combine
import UserNotifications
import Foundation

@MainActor
final class NotificationManager: NSObject, ObservableObject {
    var onSnooze: ((TimeInterval) -> Void)?

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined
    private var lastNotificationDate: Date?

    override init() {
        super.init()
        // Set delegate immediately so notification clicks are always handled
        // by this instance, preventing macOS from launching a new app instance.
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()

        let snoozeAction = UNNotificationAction(
            identifier: ActionID.snooze,
            title: String(localized: "Snooze 10 min", bundle: Bundle.sitTallResources),
            options: []
        )
        let category = UNNotificationCategory(
            identifier: CategoryID.postureAlert,
            actions: [snoozeAction],
            intentIdentifiers: [],
            options: []
        )
        center.setNotificationCategories([category])

        do {
            try await center.requestAuthorization(options: [.alert, .sound])
            await refreshAuthorizationStatus()
        } catch {
            AppLogger.notifications.error("Notification authorization error: \(error.localizedDescription, privacy: .public)")
            await refreshAuthorizationStatus()
        }
    }

    func refreshAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    func sendPostureAlert(cooldownMinutes: Double) {
        guard authorizationStatus == .authorized || authorizationStatus == .provisional else {
            AppLogger.notifications.info("Skipping posture alert because notifications are not authorized")
            return
        }
        let now = Date()
        if let last = lastNotificationDate,
           now.timeIntervalSince(last) < cooldownMinutes * 60 {
            return
        }
        lastNotificationDate = now

        let content = UNMutableNotificationContent()
        content.title = String(localized: "Posture Alert", bundle: Bundle.sitTallResources)
        content.body = String(localized: "You've been in a bad position for a while. Sit up straight!", bundle: Bundle.sitTallResources)
        content.sound = .default
        content.categoryIdentifier = CategoryID.postureAlert

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                AppLogger.notifications.error("Failed to schedule local notification: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    private enum ActionID {
        static let snooze = "snooze"
    }

    private enum CategoryID {
        static let postureAlert = "POSTURE_ALERT"
    }
}

extension UNAuthorizationStatus {
    var statusDescription: String {
        switch self {
        case .notDetermined:
            return String(localized: "Not requested", bundle: Bundle.sitTallResources)
        case .denied:
            return String(localized: "Denied", bundle: Bundle.sitTallResources)
        case .authorized:
            return String(localized: "Allowed", bundle: Bundle.sitTallResources)
        case .provisional:
            return String(localized: "Provisional", bundle: Bundle.sitTallResources)
        case .ephemeral:
            return String(localized: "Ephemeral", bundle: Bundle.sitTallResources)
        @unknown default:
            return String(localized: "Unknown", bundle: Bundle.sitTallResources)
        }
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        if response.actionIdentifier == "snooze" {
            Task { @MainActor [weak self] in
                self?.onSnooze?(10 * 60)
            }
        }
        completionHandler()
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
