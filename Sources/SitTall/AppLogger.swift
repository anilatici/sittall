import OSLog

enum AppLogger {
    static let app = Logger(subsystem: "app.sittall.SitTall", category: "app")
    static let motion = Logger(subsystem: "app.sittall.SitTall", category: "motion")
    static let analysis = Logger(subsystem: "app.sittall.SitTall", category: "analysis")
    static let notifications = Logger(subsystem: "app.sittall.SitTall", category: "notifications")
    static let lifecycle = Logger(subsystem: "app.sittall.SitTall", category: "lifecycle")
}
