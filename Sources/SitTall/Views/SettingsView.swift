import SwiftUI
import PostureCore

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsStore
    @EnvironmentObject var analyzer: PostureAnalyzer
    @EnvironmentObject var motionManager: HeadphoneMotionManager
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var diagnostics: DiagnosticsStore

    private var appVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    var body: some View {
        Form {
            // ── Detection ────────────────────────────────────────────
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(sitTallLocalized("Sensitivity"))
                        Spacer()
                        Text(sitTallLocalized("\(Int(settings.deviationDegrees))° score"))
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                    Slider(
                        value: $settings.deviationDegrees,
                        in: 5...30,
                        step: 5
                    ) {
                        EmptyView()
                    } minimumValueLabel: {
                        Text(sitTallLocalized("5°")).font(.caption)
                    } maximumValueLabel: {
                        Text(sitTallLocalized("30°")).font(.caption)
                    }
                    Text(sitTallLocalized("Alert when combined forward drift and side tilt rise above \(Int(settings.deviationDegrees))° from your calibrated posture."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Picker(sitTallLocalized("Alert after"), selection: $settings.durationSeconds) {
                    Text(sitTallLocalized("15 seconds")).tag(15.0)
                    Text(sitTallLocalized("30 seconds")).tag(30.0)
                    Text(sitTallLocalized("1 minute")).tag(60.0)
                    Text(sitTallLocalized("2 minutes")).tag(120.0)
                }
                .pickerStyle(.menu)
            } header: {
                Text(sitTallLocalized("Detection"))
            }

            // ── Notifications ────────────────────────────────────────
            Section {
                Picker(sitTallLocalized("Remind me at most every"), selection: $settings.cooldownMinutes) {
                    Text(sitTallLocalized("5 minutes")).tag(5.0)
                    Text(sitTallLocalized("10 minutes")).tag(10.0)
                    Text(sitTallLocalized("15 minutes")).tag(15.0)
                }
                .pickerStyle(.menu)

                LabeledContent(sitTallLocalized("Authorization")) {
                    Text(notificationManager.authorizationStatus.statusDescription)
                        .foregroundStyle(notificationManager.authorizationStatus == .denied ? .red : .secondary)
                }
            } header: {
                Text(sitTallLocalized("Notifications"))
            }

            // ── General ──────────────────────────────────────────────
            Section {
                Toggle(sitTallLocalized("Auto-start monitoring when AirPods connect"), isOn: $settings.autoStart)
                Toggle(sitTallLocalized("Collect local diagnostics"), isOn: $settings.localDiagnosticsEnabled)

                Button(role: .destructive) {
                    analyzer.beginRecalibration()
                } label: {
                    Label(sitTallLocalized("Reset Calibration"), systemImage: "arrow.counterclockwise")
                }
                .help(sitTallLocalized("Clear the saved baseline posture. You will need to calibrate again."))
            } header: {
                Text(sitTallLocalized("General"))
            }

            Section {
                LabeledContent(sitTallLocalized("Launches")) {
                    Text("\(diagnostics.launches)")
                }
                LabeledContent(sitTallLocalized("Calibrations")) {
                    Text("\(diagnostics.completedCalibrations)")
                }
                LabeledContent(sitTallLocalized("Alerts sent")) {
                    Text("\(diagnostics.notificationsSent)")
                }
                LabeledContent(sitTallLocalized("Disconnects")) {
                    Text("\(diagnostics.disconnectCount)")
                }
                LabeledContent(sitTallLocalized("Unexpected exits")) {
                    Text("\(diagnostics.unexpectedTerminationCount)")
                }
            } header: {
                Text(sitTallLocalized("Diagnostics"))
            } footer: {
                Text(sitTallLocalized("Diagnostics stay on this Mac and are used only for troubleshooting and release validation."))
            }

            // ── How It Works ────────────────────────────────────────
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    InfoRow(
                        title: sitTallLocalized("Health Score"),
                        detail: sitTallLocalized("The percentage of your monitored time spent in good posture. 100% means no slouching at all. The score resets each day.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Slouches"),
                        detail: sitTallLocalized("Each time your posture drifts past the sensitivity threshold for longer than the alert delay, it counts as one slouch.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Fixes"),
                        detail: sitTallLocalized("Each time you correct back to good posture after a slouch is counted as a fix.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Time Slouched"),
                        detail: sitTallLocalized("Total time spent in bad posture today.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Posture Drift"),
                        detail: sitTallLocalized("Real-time gauge showing how far your head has tilted from your calibrated good posture, in degrees.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Sensitivity"),
                        detail: sitTallLocalized("The degree threshold that triggers a slouch detection. Lower values are more sensitive.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Alert Delay"),
                        detail: sitTallLocalized("How long you must be past the threshold before SitTall - Fix Your Posture considers it a slouch and sends a notification.")
                    )
                    InfoRow(
                        title: sitTallLocalized("Calibration"),
                        detail: sitTallLocalized("Save your good and bad posture so SitTall - Fix Your Posture knows your personal range. Recalibrate any time your seating position changes.")
                    )
                }
                .padding(.vertical, 4)
            } header: {
                Text(sitTallLocalized("How It Works"))
            }

            // ── About ────────────────────────────────────────────────
            Section {
                LabeledContent(sitTallLocalized("Compatible devices")) {
                    Text(sitTallLocalized("AirPods Pro (gen 1/2/2 USB-C), AirPods (3rd gen+), AirPods Max"))
                        .foregroundStyle(.secondary)
                }
                LabeledContent(sitTallLocalized("Sensor")) {
                    Text(sitTallLocalized("CMHeadphoneMotionManager: calibrated pitch, roll, and slow drift from the built-in IMU"))
                        .foregroundStyle(.secondary)
                }
                LabeledContent(sitTallLocalized("Version")) {
                    Text(appVersion)
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(sitTallLocalized("About"))
            }

            // ── Credits ─────────────────────────────────────────────
            Section {
                LabeledContent(sitTallLocalized("German Translation")) {
                    Text("Tim Ulrich")
                        .foregroundStyle(.secondary)
                }
            } header: {
                Text(sitTallLocalized("Credits"))
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 700)
        .onChange(of: settings.autoStart) { _, enabled in
            guard motionManager.isConnected else { return }
            if enabled {
                motionManager.startMonitoring()
            } else {
                motionManager.stopMonitoring()
                analyzer.stopMonitoring()
            }
        }
        .task {
            await notificationManager.refreshAuthorizationStatus()
        }
    }
}

struct InfoRow: View {
    let title: String
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.medium))
            Text(detail)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
