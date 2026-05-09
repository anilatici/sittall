import Foundation

public enum MotionSource: String, Codable, CaseIterable, Sendable {
    case airPods
    case iPhone
    case demo

    public var displayName: String {
        switch self {
        case .airPods: return "AirPods Motion"
        case .iPhone: return "iPhone Motion"
        case .demo: return "Demo Motion"
        }
    }
}

public enum MotionAvailabilityState: String, Codable, CaseIterable, Sendable {
    case unavailable
    case disconnected
    case connected

    public var title: String {
        switch self {
        case .unavailable: return "Motion unavailable"
        case .disconnected: return "No AirPods detected"
        case .connected: return "AirPods connected"
        }
    }

    public var detail: String {
        switch self {
        case .unavailable: return "Head motion could not be started on this Mac right now."
        case .disconnected: return "Connect supported AirPods with head motion to start posture monitoring."
        case .connected: return "Head motion is available for live posture monitoring."
        }
    }
}

public enum MonitoringState: String, Codable, CaseIterable, Sendable {
    case idle
    case monitoring
    case paused
}

public enum CalibrationState: String, Codable, CaseIterable, Sendable {
    case needsGoodPosture
    case needsBadPosture
    case calibrated
}

public struct MotionSample: Codable, Sendable {
    public var timestamp: Date
    public var pitch: Double
    public var roll: Double
    public var yaw: Double
    public var confidence: Double

    public init(
        timestamp: Date = .now,
        pitch: Double,
        roll: Double,
        yaw: Double,
        confidence: Double = 1.0
    ) {
        self.timestamp = timestamp
        self.pitch = pitch
        self.roll = roll
        self.yaw = yaw
        self.confidence = confidence
    }
}

public enum PostureState: String, Codable, CaseIterable, Sendable {
    case unavailable
    case notCalibrated
    case calibrationStep2
    case good
    case warning
    case bad

    public var title: String {
        switch self {
        case .unavailable: return "Source unavailable"
        case .notCalibrated: return "Capture your good posture"
        case .calibrationStep2: return "Capture your bad posture"
        case .good: return "Good posture"
        case .warning: return "Posture drifting"
        case .bad: return "Adjust your posture"
        }
    }

    public var detail: String {
        switch self {
        case .unavailable: return "No AirPods detected. Connect supported AirPods or use iPhone mode."
        case .notCalibrated: return "Sit tall with your shoulders down and chest open."
        case .calibrationStep2: return "Now show the slouched position you want the app to catch."
        case .good: return "You are inside your calibrated range."
        case .warning: return "You are moving toward a poor posture pattern."
        case .bad: return "You have stayed outside the healthy range for too long."
        }
    }
}

public extension PostureState {
    var calibrationState: CalibrationState {
        switch self {
        case .notCalibrated:
            return .needsGoodPosture
        case .calibrationStep2:
            return .needsBadPosture
        default:
            return .calibrated
        }
    }
}

public struct CalibrationProfile: Codable, Sendable {
    public var source: MotionSource
    public var goodPitchBaseline: Double
    public var goodRollBaseline: Double
    public var pitchAlertDirection: Double

    public init(
        source: MotionSource,
        goodPitchBaseline: Double,
        goodRollBaseline: Double,
        pitchAlertDirection: Double = 1.0
    ) {
        self.source = source
        self.goodPitchBaseline = goodPitchBaseline
        self.goodRollBaseline = goodRollBaseline
        self.pitchAlertDirection = pitchAlertDirection
    }
}

public struct PostureSettings: Codable, Sendable {
    public var deviationDegreesThreshold: Double
    public var alertDurationSeconds: Double
    public var cooldownMinutes: Double
    public var rollWeight: Double
    public var minimumConfidence: Double

    public init(
        deviationDegreesThreshold: Double,
        alertDurationSeconds: Double,
        cooldownMinutes: Double,
        rollWeight: Double,
        minimumConfidence: Double = 0.2
    ) {
        self.deviationDegreesThreshold = deviationDegreesThreshold
        self.alertDurationSeconds = alertDurationSeconds
        self.cooldownMinutes = cooldownMinutes
        self.rollWeight = rollWeight
        self.minimumConfidence = minimumConfidence
    }
}
