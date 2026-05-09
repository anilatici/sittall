import Foundation
import Testing
@testable import PostureCore

@MainActor
struct PostureAnalyzerTests {
    private func makeSettings(
        threshold: Double = 15,
        duration: Double = 30,
        rollWeight: Double = 0.65
    ) -> PostureSettings {
        PostureSettings(
            deviationDegreesThreshold: threshold,
            alertDurationSeconds: duration,
            cooldownMinutes: 10,
            rollWeight: rollWeight
        )
    }

    @Test
    func calibrationFlowCapturesDirection() throws {
        let analyzer = PostureAnalyzer()
        analyzer.setSource(.airPods, calibration: nil)

        analyzer.calibrateGood(sample: MotionSample(timestamp: .now, pitch: 0.0, roll: 0.0, yaw: 0.0))
        #expect(analyzer.state == .calibrationStep2)

        analyzer.calibrateBad(sample: MotionSample(timestamp: .now, pitch: 0.2, roll: 0.0, yaw: 0.0))

        let calibration = try #require(analyzer.calibrationProfile)
        #expect(calibration.pitchAlertDirection == 1.0)
        #expect(analyzer.state == .good)
    }

    @Test
    func driftTriggersBadPostureAfterDuration() {
        let analyzer = PostureAnalyzer()
        let calibration = CalibrationProfile(
            source: .airPods,
            goodPitchBaseline: 0.0,
            goodRollBaseline: 0.0,
            pitchAlertDirection: 1.0
        )
        let settings = makeSettings(duration: 5)
        analyzer.setSource(.airPods, calibration: calibration)

        // EMA (alpha=0.15) needs ~9 samples at 0.35 rad to exceed the 15° threshold.
        // Feed 10 samples at the same timestamp so badPostureStart is anchored there.
        let start = Date.now
        for _ in 0..<10 {
            analyzer.update(
                sample: MotionSample(timestamp: start, pitch: 0.35, roll: 0.0, yaw: 0.0),
                settings: settings
            )
        }
        #expect(analyzer.state == .warning)

        analyzer.update(
            sample: MotionSample(timestamp: start.addingTimeInterval(6), pitch: 0.35, roll: 0.0, yaw: 0.0),
            settings: settings
        )
        #expect(analyzer.state == .bad)
    }

    @Test
    func rollContributesSymmetrically() {
        let analyzer = PostureAnalyzer()
        let calibration = CalibrationProfile(
            source: .airPods,
            goodPitchBaseline: 0.0,
            goodRollBaseline: 0.0,
            pitchAlertDirection: 1.0
        )
        analyzer.setSource(.airPods, calibration: calibration)
        let settings = makeSettings(threshold: 5, rollWeight: 1.0)

        analyzer.update(
            sample: MotionSample(timestamp: .now, pitch: 0.0, roll: 0.2, yaw: 0.0),
            settings: settings
        )
        let positiveScore = analyzer.postureScoreDegrees

        analyzer.stopMonitoring()
        analyzer.setSource(.airPods, calibration: calibration)
        analyzer.update(
            sample: MotionSample(timestamp: .now, pitch: 0.0, roll: -0.2, yaw: 0.0),
            settings: settings
        )
        let negativeScore = analyzer.postureScoreDegrees

        #expect(abs(positiveScore - negativeScore) < 0.1)
    }

    @Test
    func recalibrationClearsCalibration() {
        let analyzer = PostureAnalyzer()
        let calibration = CalibrationProfile(
            source: .airPods,
            goodPitchBaseline: 0.0,
            goodRollBaseline: 0.0,
            pitchAlertDirection: 1.0
        )
        analyzer.setSource(.airPods, calibration: calibration)

        analyzer.beginRecalibration()

        #expect(analyzer.calibrationProfile == nil)
        #expect(analyzer.state == .notCalibrated)
    }

    @Test
    func unavailableStateKeepsCalibrationForReconnect() {
        let analyzer = PostureAnalyzer()
        let calibration = CalibrationProfile(
            source: .airPods,
            goodPitchBaseline: 0.0,
            goodRollBaseline: 0.1,
            pitchAlertDirection: -1.0
        )
        analyzer.setSource(.airPods, calibration: calibration)

        analyzer.resetForUnavailable(keeping: calibration)

        #expect(analyzer.state == .unavailable)
        #expect(analyzer.calibrationProfile?.pitchAlertDirection == -1.0)
    }
}
