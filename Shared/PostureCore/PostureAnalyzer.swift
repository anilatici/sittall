import Combine
import Foundation

@MainActor
public final class PostureAnalyzer: ObservableObject {
    @Published public private(set) var state: PostureState = .unavailable
    @Published public private(set) var postureScoreDegrees: Double = 0
    @Published public private(set) var currentSource: MotionSource?
    @Published public private(set) var calibrationProfile: CalibrationProfile?

    public var onBadPosture: (() -> Void)?
    public var onStateChange: ((PostureState) -> Void)?

    private var smoothedPitch = 0.0
    private var smoothedRoll = 0.0
    private var driftPitch = 0.0
    private var badPostureStart: Date?
    private var notifiedThisSpell = false

    private let emaAlpha = 0.15
    private let driftAlpha = 0.04

    public init() {}

    public func setSource(_ source: MotionSource?, calibration: CalibrationProfile?) {
        currentSource = source
        calibrationProfile = calibration
        postureScoreDegrees = 0
        badPostureStart = nil
        notifiedThisSpell = false

        if let calibration {
            smoothedPitch = calibration.goodPitchBaseline
            smoothedRoll = calibration.goodRollBaseline
            driftPitch = calibration.goodPitchBaseline
            transition(to: .good)
        } else if source != nil {
            smoothedPitch = 0
            smoothedRoll = 0
            driftPitch = 0
            transition(to: .notCalibrated)
        } else {
            smoothedPitch = 0
            smoothedRoll = 0
            driftPitch = 0
            transition(to: .unavailable)
        }
    }

    public var isCalibrated: Bool {
        calibrationProfile != nil && state.calibrationState == .calibrated
    }

    public func update(sample: MotionSample, settings: PostureSettings) {
        guard currentSource != nil else {
            transition(to: .unavailable)
            return
        }
        guard sample.confidence >= settings.minimumConfidence else { return }
        guard let calibrationProfile else {
            transition(to: .notCalibrated)
            return
        }

        smoothedPitch = emaAlpha * sample.pitch + (1 - emaAlpha) * smoothedPitch
        smoothedRoll = emaAlpha * sample.roll + (1 - emaAlpha) * smoothedRoll
        driftPitch = driftAlpha * sample.pitch + (1 - driftAlpha) * driftPitch

        guard state != .calibrationStep2 else {
            postureScoreDegrees = 0
            return
        }

        let pitchTowardBad = max(
            0,
            (smoothedPitch - calibrationProfile.goodPitchBaseline) * calibrationProfile.pitchAlertDirection
        ) * 180 / .pi
        let driftTowardBad = max(
            0,
            (driftPitch - calibrationProfile.goodPitchBaseline) * calibrationProfile.pitchAlertDirection
        ) * 180 / .pi
        let rollAwayFromBaseline = abs(smoothedRoll - calibrationProfile.goodRollBaseline) * 180 / .pi

        postureScoreDegrees = max(pitchTowardBad, driftTowardBad) + (rollAwayFromBaseline * settings.rollWeight)

        if postureScoreDegrees < settings.deviationDegreesThreshold {
            badPostureStart = nil
            notifiedThisSpell = false
            transition(to: .good)
            return
        }

        let now = sample.timestamp
        if badPostureStart == nil {
            badPostureStart = now
        }

        let elapsed = now.timeIntervalSince(badPostureStart ?? now)
        if elapsed >= settings.alertDurationSeconds {
            transition(to: .bad)
            if !notifiedThisSpell {
                notifiedThisSpell = true
                onBadPosture?()
            }
        } else {
            transition(to: .warning)
        }
    }

    public func calibrateGood(sample: MotionSample) {
        guard let currentSource else { return }
        let profile = CalibrationProfile(
            source: currentSource,
            goodPitchBaseline: sample.pitch,
            goodRollBaseline: sample.roll
        )
        calibrationProfile = profile
        smoothedPitch = sample.pitch
        smoothedRoll = sample.roll
        driftPitch = sample.pitch
        postureScoreDegrees = 0
        badPostureStart = nil
        notifiedThisSpell = false
        transition(to: .calibrationStep2)
    }

    public func calibrateBad(sample: MotionSample) {
        guard var calibrationProfile else { return }
        let diff = sample.pitch - calibrationProfile.goodPitchBaseline
        if abs(diff) > 0.035 {
            calibrationProfile.pitchAlertDirection = diff > 0 ? 1.0 : -1.0
        }
        self.calibrationProfile = calibrationProfile
        smoothedPitch = calibrationProfile.goodPitchBaseline
        driftPitch = calibrationProfile.goodPitchBaseline
        smoothedRoll = calibrationProfile.goodRollBaseline
        postureScoreDegrees = 0
        badPostureStart = nil
        notifiedThisSpell = false
        transition(to: .good)
    }

    public func beginRecalibration() {
        calibrationProfile = nil
        postureScoreDegrees = 0
        badPostureStart = nil
        notifiedThisSpell = false
        transition(to: currentSource == nil ? .unavailable : .notCalibrated)
    }

    public func stopMonitoring() {
        postureScoreDegrees = 0
        badPostureStart = nil
        notifiedThisSpell = false
        if currentSource == nil {
            transition(to: .unavailable)
        } else if calibrationProfile == nil {
            transition(to: .notCalibrated)
        } else {
            transition(to: .good)
        }
    }

    public func resetForUnavailable(keeping calibration: CalibrationProfile?) {
        currentSource = nil
        calibrationProfile = calibration
        postureScoreDegrees = 0
        badPostureStart = nil
        notifiedThisSpell = false
        smoothedPitch = calibration?.goodPitchBaseline ?? 0
        smoothedRoll = calibration?.goodRollBaseline ?? 0
        driftPitch = calibration?.goodPitchBaseline ?? 0
        transition(to: .unavailable)
    }

    private func transition(to newState: PostureState) {
        guard newState != state else { return }
        state = newState
        onStateChange?(newState)
    }
}
