import Combine
import Foundation
import PostureCore

@MainActor
final class DailyStatsStore: ObservableObject {
    // MARK: – Persisted stats

    @Published private(set) var slouchCount: Int {
        didSet { UserDefaults.standard.set(slouchCount, forKey: Keys.slouchCount) }
    }
    @Published private(set) var correctionCount: Int {
        didSet { UserDefaults.standard.set(correctionCount, forKey: Keys.correctionCount) }
    }
    @Published private(set) var totalSlouchSeconds: Double {
        didSet { UserDefaults.standard.set(totalSlouchSeconds, forKey: Keys.totalSlouchSeconds) }
    }
    @Published private(set) var totalMonitoredSeconds: Double {
        didSet { UserDefaults.standard.set(totalMonitoredSeconds, forKey: Keys.totalMonitoredSeconds) }
    }
    @Published private(set) var statsDate: String {
        didSet { UserDefaults.standard.set(statsDate, forKey: Keys.statsDate) }
    }

    // MARK: – Transient state

    private var previousState: PostureState?
    private var lastMonitoringTick: Date?

    private static let activeStates: Set<PostureState> = [.good, .warning, .bad]

    // MARK: – Init

    init() {
        let defaults = UserDefaults.standard
        slouchCount = defaults.integer(forKey: Keys.slouchCount)
        correctionCount = defaults.integer(forKey: Keys.correctionCount)
        totalSlouchSeconds = defaults.double(forKey: Keys.totalSlouchSeconds)
        totalMonitoredSeconds = defaults.double(forKey: Keys.totalMonitoredSeconds)
        statsDate = defaults.string(forKey: Keys.statsDate) ?? Self.todayString()

        resetIfNewDay()
    }

    // MARK: – Recording

    /// Called on every posture state change from the analyzer.
    func recordState(_ newState: PostureState) {
        resetIfNewDay()
        let now = Date()

        // Accumulate time from previous state
        accumulateTime(now: now)

        // Update tick for new state
        if Self.activeStates.contains(newState) {
            lastMonitoringTick = now
        } else {
            lastMonitoringTick = nil
        }

        // Detect transitions
        if let prev = previousState {
            // Entered bad posture
            if newState == .bad && prev != .bad && Self.activeStates.contains(prev) {
                slouchCount += 1
            }
            // Fixed posture after being bad
            if prev == .bad && (newState == .good || newState == .warning) {
                correctionCount += 1
            }
        }

        previousState = newState
    }

    /// Called periodically (every 30s) to keep time counters updated.
    func tick(currentState: PostureState) {
        resetIfNewDay()
        guard Self.activeStates.contains(currentState), lastMonitoringTick != nil else { return }
        accumulateTime(now: Date())
        lastMonitoringTick = Date()
    }

    // MARK: – Computed properties

    var healthScore: Int {
        guard totalMonitoredSeconds >= 60 else { return 100 }
        let goodRatio = max(0, 1.0 - (totalSlouchSeconds / totalMonitoredSeconds))
        return Int((goodRatio * 100).rounded())
    }

    var formattedSlouchTime: String {
        formatDuration(totalSlouchSeconds)
    }

    var formattedMonitoredTime: String {
        formatDuration(totalMonitoredSeconds)
    }

    var shareSummary: String {
        let title = String(localized: "share.title", bundle: Bundle.sitTallResources)
        let score = String(localized: "share.healthScore \(healthScore)", bundle: Bundle.sitTallResources)
        let slouches = String(localized: "share.slouches \(slouchCount)", bundle: Bundle.sitTallResources)
        let time = String(localized: "share.timeSlouched \(formattedSlouchTime)", bundle: Bundle.sitTallResources)
        let corrections = String(localized: "share.corrections \(correctionCount)", bundle: Bundle.sitTallResources)
        let monitored = String(localized: "share.monitored \(formattedMonitoredTime)", bundle: Bundle.sitTallResources)
        return """
        \(title)
        \(score)
        \(slouches)
        \(time)
        \(corrections)
        \(monitored)
        """
    }

    // MARK: – Private

    private func accumulateTime(now: Date) {
        guard let tick = lastMonitoringTick else { return }
        let elapsed = now.timeIntervalSince(tick)
        guard elapsed > 0 else { return }

        if let prev = previousState, Self.activeStates.contains(prev) {
            totalMonitoredSeconds += elapsed
            if prev == .bad {
                totalSlouchSeconds += elapsed
            }
        }
    }

    private func resetIfNewDay() {
        let today = Self.todayString()
        guard today != statsDate else { return }
        slouchCount = 0
        correctionCount = 0
        totalSlouchSeconds = 0
        totalMonitoredSeconds = 0
        statsDate = today
        previousState = nil
        lastMonitoringTick = nil
    }

    private static func todayString() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        fmt.calendar = Calendar.current
        return fmt.string(from: Date())
    }

    private func formatDuration(_ seconds: Double) -> String {
        let totalMinutes = Int(seconds) / 60
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        if hours > 0 {
            return String(localized: "\(hours)h \(minutes)m", bundle: Bundle.sitTallResources)
        }
        return String(localized: "\(minutes)m", bundle: Bundle.sitTallResources)
    }

    private enum Keys {
        static let slouchCount = "dailyStats.slouchCount"
        static let correctionCount = "dailyStats.correctionCount"
        static let totalSlouchSeconds = "dailyStats.totalSlouchSeconds"
        static let totalMonitoredSeconds = "dailyStats.totalMonitoredSeconds"
        static let statsDate = "dailyStats.date"
    }
}
