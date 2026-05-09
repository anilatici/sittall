import SwiftUI
import PostureCore

struct MenuContentView: View {
    @EnvironmentObject var analyzer: PostureAnalyzer
    @EnvironmentObject var motionManager: HeadphoneMotionManager
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var diagnostics: DiagnosticsStore
    @EnvironmentObject var dailyStats: DailyStatsStore
    @Environment(\.openSettings) private var openSettings

    private var calibrationButtonLabel: String {
        switch analyzer.state.calibrationState {
        case .needsBadPosture:
            return String(localized: "Save Bad Posture", bundle: Bundle.sitTallResources)
        case .needsGoodPosture:
            return String(localized: "Save Good Posture", bundle: Bundle.sitTallResources)
        case .calibrated:
            return String(localized: "Recalibrate Posture", bundle: Bundle.sitTallResources)
        }
    }

    private var calibrationHelpText: String? {
        switch analyzer.state.calibrationState {
        case .needsGoodPosture:
            return String(localized: "Sit tall with shoulders back, then save your good posture.", bundle: Bundle.sitTallResources)
        case .needsBadPosture:
            return String(localized: "Now slouch or crane forward a bit, then save that as bad posture.", bundle: Bundle.sitTallResources)
        case .calibrated:
            return nil
        }
    }

    /// AirPods are Bluetooth-connected but not on the head (case/desk).
    /// isDeviceMotionAvailable stays true via BT, but no motion callbacks arrive.
    private var airPodsNotWorn: Bool {
        motionManager.availabilityState == .connected
            && motionManager.isMonitoring
            && !motionManager.hasFreshSample
    }

    private var statusTitle: String {
        if motionManager.availabilityState != .connected || airPodsNotWorn {
            return String(localized: "No AirPods detected", bundle: Bundle.sitTallResources)
        }
        return analyzer.state.statusDescription
    }

    private var statusDetail: String {
        if airPodsNotWorn {
            return String(localized: "Put your AirPods on to resume monitoring.", bundle: Bundle.sitTallResources)
        }
        if motionManager.availabilityState != .connected {
            return motionManager.availabilityState.secondaryText
        }
        if analyzer.state == .unavailable {
            return motionManager.availabilityState.secondaryText
        }
        if notificationManager.authorizationStatus == .denied {
            return String(localized: "Notifications are disabled. Enable them in System Settings to receive reminders.", bundle: Bundle.sitTallResources)
        }
        if let calibrationHelpText {
            return calibrationHelpText
        }
        switch motionManager.monitoringState {
        case .monitoring:
            return String(localized: "Monitoring active", bundle: Bundle.sitTallResources)
        case .paused:
            return String(localized: "Monitoring paused", bundle: Bundle.sitTallResources)
        case .idle:
            return String(localized: "Monitoring stopped", bundle: Bundle.sitTallResources)
        }
    }

    private var canCaptureCalibration: Bool {
        motionManager.availabilityState == .connected && motionManager.hasFreshSample && motionManager.currentSample != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // ── Header ──────────────────────────────────────────────
            HStack(spacing: 10) {
                Image(systemName: (motionManager.availabilityState == .connected && !airPodsNotWorn) ? analyzer.state.symbolName : "ear.and.waveform")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle((motionManager.availabilityState == .connected && !airPodsNotWorn) ? analyzer.state.swiftUIColor : Color.secondary)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(statusTitle)
                        .font(.headline)
                    Text(statusDetail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)

            // ── Deviation gauge ─────────────────────────────────────
            if motionManager.availabilityState == .connected, !airPodsNotWorn,
               (analyzer.state == .good || analyzer.state == .warning || analyzer.state == .bad) {
                DeviationGauge(
                    deviationDeg: analyzer.postureScoreDegrees,
                    thresholdDeg: settings.deviationDegrees
                )
                .padding(.horizontal, 14)
                .padding(.bottom, 10)
            }

            // ── Daily Stats ─────────────────────────────────────────
            if motionManager.availabilityState == .connected, !airPodsNotWorn,
               analyzer.state == .good || analyzer.state == .warning || analyzer.state == .bad {
                DailyStatsSection(dailyStats: dailyStats)
                    .padding(.horizontal, 14)
                    .padding(.bottom, 10)
            }

            Divider()

            // ── Controls ─────────────────────────────────────────────
            VStack(alignment: .leading, spacing: 2) {
                if motionManager.availabilityState == .connected && !airPodsNotWorn {
                    MenuButton(
                        label: calibrationButtonLabel,
                        icon: "scope",
                        prominent: analyzer.state.calibrationState != .calibrated
                    ) {
                        if analyzer.state.calibrationState == .needsBadPosture {
                            guard let sample = motionManager.currentSample else { return }
                            analyzer.calibrateBad(sample: sample)
                            diagnostics.recordCalibrationCompleted(enabled: settings.localDiagnosticsEnabled)
                        } else if analyzer.state.calibrationState == .needsGoodPosture {
                            guard let sample = motionManager.currentSample else { return }
                            analyzer.calibrateGood(sample: sample)
                        } else {
                            analyzer.beginRecalibration()
                        }
                        if !motionManager.isMonitoring {
                            motionManager.startMonitoring()
                        }
                    }
                    .disabled(analyzer.state.calibrationState != .calibrated && !canCaptureCalibration)

                    if motionManager.isPaused {
                        MenuButton(label: sitTallLocalized("Resume Monitoring"), icon: "play.circle") {
                            motionManager.startMonitoring()
                        }
                    } else if !motionManager.isMonitoring {
                        MenuButton(label: sitTallLocalized("Start Monitoring"), icon: "play.circle") {
                            motionManager.startMonitoring()
                        }
                    }
                }

                if notificationManager.authorizationStatus == .denied {
                    Text(sitTallLocalized("Notifications are off for SitTall - Fix Your Posture in System Settings."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.top, 4)
                }

                Divider().padding(.vertical, 4)

                MenuButton(label: sitTallLocalized("Settings…"), icon: "gearshape") {
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                }

                MenuButton(label: sitTallLocalized("Quit SitTall - Fix Your Posture"), icon: "power") {
                    NSApp.terminate(nil)
                }
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .frame(width: 300)
        .task {
            await notificationManager.refreshAuthorizationStatus()
        }
    }
}

// MARK: – Reusable sub-views

struct DeviationGauge: View {
    let deviationDeg: Double
    let thresholdDeg: Double

    private var towardBadDegrees: Double { max(deviationDeg, 0) }
    private var ratio: Double { min(towardBadDegrees / (thresholdDeg * 1.5), 1.0) }
    private var gaugeColor: Color {
        let r = towardBadDegrees / thresholdDeg
        if r < 0.6 { return .green }
        if r < 1.0 { return .yellow }
        return .red
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(sitTallLocalized("Posture drift"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text(sitTallLocalized("\(Int(towardBadDegrees.rounded()))° toward bad posture"))
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.secondary.opacity(0.18))
                        .frame(height: 6)
                    Capsule()
                        .fill(gaugeColor.gradient)
                        .frame(width: max(6, geo.size.width * ratio), height: 6)
                        .animation(.spring(duration: 0.3), value: ratio)
                }
            }
            .frame(height: 6)
        }
    }
}

struct MenuButton: View {
    let label: String
    let icon: String
    var prominent = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(label, systemImage: icon)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(MenuButtonStyle(prominent: prominent))
    }
}

// MARK: – Daily Stats

struct DailyStatsSection: View {
    @ObservedObject var dailyStats: DailyStatsStore
    @Environment(\.openSettings) private var openSettings

    private var scoreColor: Color {
        switch dailyStats.healthScore {
        case 80...100: return .green
        case 50..<80: return .yellow
        default: return .red
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(sitTallLocalized("Today's Score"))
                    .font(.caption.weight(.medium))
                Button {
                    openSettings()
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Image(systemName: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help(sitTallLocalized("How scores are calculated"))
                Spacer()
                Text("\(dailyStats.healthScore)%")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(scoreColor)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.secondary.opacity(0.18))
                        .frame(height: 6)
                    Capsule()
                        .fill(scoreColor.gradient)
                        .frame(width: max(6, geo.size.width * Double(dailyStats.healthScore) / 100), height: 6)
                        .animation(.spring(duration: 0.3), value: dailyStats.healthScore)
                }
            }
            .frame(height: 6)

            HStack(spacing: 6) {
                StatPill(icon: "arrow.down.forward", value: "\(dailyStats.slouchCount)", label: sitTallLocalized("Slouches"))
                StatPill(icon: "arrow.up.forward", value: "\(dailyStats.correctionCount)", label: sitTallLocalized("Fixes"))
                StatPill(icon: "clock", value: dailyStats.formattedSlouchTime, label: sitTallLocalized("Slouched"))
            }

            ShareStatsButton(summary: dailyStats.shareSummary)
        }
    }
}

struct StatPill: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 3) {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .semibold))
                Text(value)
                    .font(.caption2.weight(.semibold).monospacedDigit())
            }
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(.secondary.opacity(0.08))
        )
    }
}

struct ShareStatsButton: View {
    let summary: String

    var body: some View {
        Button {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(summary, forType: .string)

            // Show the sharing picker anchored to the popover's content view
            if let contentView = NSApp.keyWindow?.contentView {
                let picker = NSSharingServicePicker(items: [summary as NSString])
                picker.show(relativeTo: .zero, of: contentView, preferredEdge: .minY)
            }
        } label: {
            Label(sitTallLocalized("Share Today's Stats"), systemImage: "square.and.arrow.up")
                .font(.caption)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
    }
}

struct MenuButtonStyle: ButtonStyle {
    let prominent: Bool
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(prominent ? .body.weight(.semibold) : .body)
            .foregroundStyle(prominent ? .white : .primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(prominent
                        ? (configuration.isPressed ? Color.accentColor.opacity(0.8) : Color.accentColor)
                        : (configuration.isPressed ? Color.secondary.opacity(0.25) : Color.clear)
                    )
            )
            .opacity(isEnabled ? 1.0 : 0.45)
    }
}
