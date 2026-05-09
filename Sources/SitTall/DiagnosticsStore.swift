import Combine
import Foundation

@MainActor
final class DiagnosticsStore: ObservableObject {
    @Published private(set) var launches: Int {
        didSet { UserDefaults.standard.set(launches, forKey: Keys.launches) }
    }
    @Published private(set) var completedCalibrations: Int {
        didSet { UserDefaults.standard.set(completedCalibrations, forKey: Keys.completedCalibrations) }
    }
    @Published private(set) var notificationsSent: Int {
        didSet { UserDefaults.standard.set(notificationsSent, forKey: Keys.notificationsSent) }
    }
    @Published private(set) var disconnectCount: Int {
        didSet { UserDefaults.standard.set(disconnectCount, forKey: Keys.disconnectCount) }
    }
    @Published private(set) var unexpectedTerminationCount: Int {
        didSet { UserDefaults.standard.set(unexpectedTerminationCount, forKey: Keys.unexpectedTerminationCount) }
    }

    init() {
        let defaults = UserDefaults.standard
        launches = defaults.integer(forKey: Keys.launches)
        completedCalibrations = defaults.integer(forKey: Keys.completedCalibrations)
        notificationsSent = defaults.integer(forKey: Keys.notificationsSent)
        disconnectCount = defaults.integer(forKey: Keys.disconnectCount)
        unexpectedTerminationCount = defaults.integer(forKey: Keys.unexpectedTerminationCount)
    }

    func recordLaunch(enabled: Bool) {
        guard enabled else { return }
        launches += 1
    }

    func recordCalibrationCompleted(enabled: Bool) {
        guard enabled else { return }
        completedCalibrations += 1
    }

    func recordNotificationSent(enabled: Bool) {
        guard enabled else { return }
        notificationsSent += 1
    }

    func recordDisconnect(enabled: Bool) {
        guard enabled else { return }
        disconnectCount += 1
    }

    func recordUnexpectedTermination(enabled: Bool) {
        guard enabled else { return }
        unexpectedTerminationCount += 1
    }

    private enum Keys {
        static let launches = "diagnostics.launches"
        static let completedCalibrations = "diagnostics.completedCalibrations"
        static let notificationsSent = "diagnostics.notificationsSent"
        static let disconnectCount = "diagnostics.disconnectCount"
        static let unexpectedTerminationCount = "diagnostics.unexpectedTerminationCount"
    }
}
