import Combine
import Foundation
import PostureCore

@MainActor
final class SettingsStore: ObservableObject {
    @Published var deviationDegrees: Double {
        didSet {
            let clamped = Self.clamp(deviationDegrees, min: 5, max: 30, fallback: 15)
            if clamped != deviationDegrees { deviationDegrees = clamped; return }
            UserDefaults.standard.set(deviationDegrees, forKey: Keys.deviationDegrees)
        }
    }
    @Published var durationSeconds: Double {
        didSet {
            let clamped = Self.clamp(durationSeconds, min: 15, max: 120, fallback: 30)
            if clamped != durationSeconds { durationSeconds = clamped; return }
            UserDefaults.standard.set(durationSeconds, forKey: Keys.durationSeconds)
        }
    }
    @Published var cooldownMinutes: Double {
        didSet {
            let normalized = Self.normalizeCooldownMinutes(cooldownMinutes)
            if normalized != cooldownMinutes { cooldownMinutes = normalized; return }
            UserDefaults.standard.set(cooldownMinutes, forKey: Keys.cooldownMinutes)
        }
    }
    @Published var autoStart: Bool {
        didSet { UserDefaults.standard.set(autoStart, forKey: Keys.autoStart) }
    }
    @Published var localDiagnosticsEnabled: Bool {
        didSet { UserDefaults.standard.set(localDiagnosticsEnabled, forKey: Keys.localDiagnosticsEnabled) }
    }
    @Published var settingsSchemaVersion: Int {
        didSet { UserDefaults.standard.set(settingsSchemaVersion, forKey: Keys.settingsSchemaVersion) }
    }

    var deviationRadians: Double { deviationDegrees * .pi / 180 }
    var postureSettings: PostureSettings {
        PostureSettings(
            deviationDegreesThreshold: deviationDegrees,
            alertDurationSeconds: durationSeconds,
            cooldownMinutes: cooldownMinutes,
            rollWeight: 0.65
        )
    }

    init() {
        let ud = UserDefaults.standard
        deviationDegrees = Self.clamp(
            ud.object(forKey: Keys.deviationDegrees) != nil ? ud.double(forKey: Keys.deviationDegrees) : 15,
            min: 5,
            max: 30,
            fallback: 15
        )
        durationSeconds = Self.clamp(
            ud.object(forKey: Keys.durationSeconds) != nil ? ud.double(forKey: Keys.durationSeconds) : 30,
            min: 15,
            max: 120,
            fallback: 30
        )
        cooldownMinutes = Self.clamp(
            Self.normalizeCooldownMinutes(
                ud.object(forKey: Keys.cooldownMinutes) != nil ? ud.double(forKey: Keys.cooldownMinutes) : 10
            ),
            min: 5,
            max: 15,
            fallback: 10
        )
        autoStart = ud.object(forKey: Keys.autoStart) != nil
            ? ud.bool(forKey: Keys.autoStart) : true
        localDiagnosticsEnabled = ud.object(forKey: Keys.localDiagnosticsEnabled) != nil
            ? ud.bool(forKey: Keys.localDiagnosticsEnabled) : false
        settingsSchemaVersion = ud.object(forKey: Keys.settingsSchemaVersion) != nil
            ? ud.integer(forKey: Keys.settingsSchemaVersion) : 1
    }

    private enum Keys {
        static let deviationDegrees = "deviationDegrees"
        static let durationSeconds  = "durationSeconds"
        static let cooldownMinutes  = "cooldownMinutes"
        static let autoStart        = "autoStart"
        static let localDiagnosticsEnabled = "localDiagnosticsEnabled"
        static let settingsSchemaVersion = "settingsSchemaVersion"
    }

    private static func clamp(_ value: Double, min: Double, max: Double, fallback: Double) -> Double {
        guard value.isFinite else { return fallback }
        return Swift.max(min, Swift.min(max, value))
    }

    private static func normalizeCooldownMinutes(_ value: Double) -> Double {
        guard value.isFinite else { return 10 }

        switch value {
        case ..<7.5:
            return 5
        case ..<12.5:
            return 10
        default:
            return 15
        }
    }
}
