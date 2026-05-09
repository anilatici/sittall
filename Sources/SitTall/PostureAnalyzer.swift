import AppKit
import PostureCore
import SwiftUI

extension PostureState {
    var statusDescription: String {
        switch self {
        case .unavailable:
            return "No supported AirPods connected"
        case .notCalibrated:
            return "Step 1: Set good posture"
        case .calibrationStep2:
            return "Step 2: Set bad posture"
        case .good:
            return "Good posture"
        case .warning:
            return "Watch your posture"
        case .bad:
            return "Fix your posture"
        }
    }

    var symbolName: String {
        switch self {
        case .unavailable:
            return "ear.and.waveform"
        case .notCalibrated, .calibrationStep2, .good, .warning, .bad:
            return "figure.stand"
        }
    }

    var color: NSColor {
        switch self {
        case .unavailable:
            return .secondaryLabelColor
        case .notCalibrated:
            return .systemOrange
        case .calibrationStep2, .warning:
            return .systemYellow
        case .good:
            return .systemGreen
        case .bad:
            return .systemRed
        }
    }

    var swiftUIColor: Color {
        switch self {
        case .unavailable:
            return .secondary
        case .notCalibrated:
            return .orange
        case .calibrationStep2, .warning:
            return .yellow
        case .good:
            return .green
        case .bad:
            return .red
        }
    }
}

extension MotionAvailabilityState {
    var statusDescription: String {
        switch self {
        case .unavailable:
            return "Head motion unavailable"
        case .disconnected:
            return "Connect supported AirPods"
        case .connected:
            return "AirPods connected"
        }
    }

    var secondaryText: String {
        switch self {
        case .unavailable:
            return "Head motion could not be started on this Mac."
        case .disconnected:
            return "Requires supported AirPods with head motion."
        case .connected:
            return "Ready to calibrate or monitor posture."
        }
    }
}
