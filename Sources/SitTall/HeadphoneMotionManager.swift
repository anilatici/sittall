import Combine
import CoreMotion
import Foundation
import PostureCore

@MainActor
final class HeadphoneMotionManager: NSObject, ObservableObject {
    @Published private(set) var availabilityState: MotionAvailabilityState = .disconnected
    @Published private(set) var monitoringState: MonitoringState = .idle
    @Published private(set) var currentSample: MotionSample?
    @Published private(set) var lastErrorDescription: String?
    @Published private(set) var lastSampleDate: Date?

    var onMotionUpdate: ((MotionSample) -> Void)?
    var onAvailabilityChanged: ((MotionAvailabilityState) -> Void)?
    var onError: ((String) -> Void)?

    private let cm = CMHeadphoneMotionManager()
    private var pauseTask: Task<Void, Never>?
    private var pollingTask: Task<Void, Never>?
    private var retryTask: Task<Void, Never>?
    private var hasScheduledRetry = false
    private var stalePolls = 0          // consecutive polls with no fresh sample

    var isConnected: Bool { availabilityState == .connected }
    var isMonitoring: Bool { monitoringState == .monitoring }
    var isPaused: Bool { monitoringState == .paused }
    var hasFreshSample: Bool {
        guard let lastSampleDate else { return false }
        return Date().timeIntervalSince(lastSampleDate) <= 2
    }

    func setup() {
        cm.delegate = self
        refreshAvailability()
        startPolling()
    }

    private func startPolling() {
        pollingTask?.cancel()
        pollingTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(2))
                guard !Task.isCancelled else { return }
                await MainActor.run { [weak self] in
                    self?.pollTick()
                }
            }
        }
    }

    private func pollTick() {
        refreshAvailability()

        // If monitoring is active but no data is flowing, the CoreMotion session may have
        // gone stale (e.g. AirPods were put back in case and the callback pipeline broke).
        // Restart it after ~10 seconds so a fresh startDeviceMotionUpdates picks up
        // as soon as the AirPods are worn again.
        if availabilityState == .connected && monitoringState == .monitoring && !hasFreshSample {
            stalePolls += 1
            if stalePolls >= 5 {
                stalePolls = 0
                AppLogger.motion.info("Restarting stale motion session (no data for ~10 s)")
                stopMonitoring()
                startMonitoring()
            }
        } else {
            stalePolls = 0
        }
    }

    func startMonitoring() {
        guard !isMonitoring else { return }
        guard cm.isDeviceMotionAvailable else {
            // isDeviceMotionAvailable can be momentarily false right after a connect event.
            // Schedule one retry so the race condition self-heals within ~2 seconds.
            if !hasScheduledRetry {
                hasScheduledRetry = true
                retryTask?.cancel()
                retryTask = Task { [weak self] in
                    try? await Task.sleep(for: .seconds(2))
                    guard !Task.isCancelled else { return }
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        self.hasScheduledRetry = false
                        self.startMonitoring()
                    }
                }
            }
            return
        }
        hasScheduledRetry = false
        retryTask?.cancel()
        pauseTask?.cancel()
        monitoringState = .monitoring
        lastErrorDescription = nil
        refreshAvailability()
        AppLogger.motion.info("Starting headphone motion updates")

        cm.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            MainActor.assumeIsolated {
                guard let self else { return }
                if let error {
                    self.recordError("Head motion update failed: \(error.localizedDescription)")
                    self.stopMonitoring()
                    return
                }
                guard let motion else { return }
                if self.availabilityState != .connected {
                    self.updateAvailability(.connected)
                }
                self.stalePolls = 0
                let sample = MotionSample(
                    timestamp: .now,
                    pitch: motion.attitude.pitch,
                    roll: motion.attitude.roll,
                    yaw: motion.attitude.yaw,
                    confidence: 1.0
                )
                self.currentSample = sample
                self.lastSampleDate = sample.timestamp
                self.onMotionUpdate?(sample)
            }
        }
    }

    func stopMonitoring() {
        pauseTask?.cancel()
        retryTask?.cancel()
        stalePolls = 0
        cm.stopDeviceMotionUpdates()
        monitoringState = .idle
        AppLogger.motion.info("Stopped headphone motion updates")
    }

    func pauseMonitoring(for duration: TimeInterval) {
        stopMonitoring()
        monitoringState = .paused
        pauseTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                guard let self else { return }
                self.monitoringState = .idle
                self.startMonitoring()
            }
        }
    }

    private func refreshAvailability() {
        updateAvailability(cm.isDeviceMotionAvailable ? .connected : .disconnected)
    }

    private func updateAvailability(_ newState: MotionAvailabilityState) {
        guard availabilityState != newState else { return }
        availabilityState = newState
        onAvailabilityChanged?(newState)
    }

    private func recordError(_ message: String) {
        lastErrorDescription = message
        AppLogger.motion.error("\(message, privacy: .public)")
        onError?(message)
    }

    deinit {
        pollingTask?.cancel()
        retryTask?.cancel()
        pauseTask?.cancel()
    }
}

extension HeadphoneMotionManager: CMHeadphoneMotionManagerDelegate {
    nonisolated func headphoneMotionManagerDidConnect(_ manager: CMHeadphoneMotionManager) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.updateAvailability(.connected)
            AppLogger.motion.info("Detected supported AirPods connection")
        }
    }

    nonisolated func headphoneMotionManagerDidDisconnect(_ manager: CMHeadphoneMotionManager) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            self.stopMonitoring()
            self.currentSample = nil
            self.lastSampleDate = nil
            self.updateAvailability(.disconnected)
            AppLogger.motion.info("Detected AirPods disconnection")
        }
    }
}
