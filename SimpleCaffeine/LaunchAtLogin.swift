import ServiceManagement
import os.log

enum LaunchAtLogin {
    private static let log = Logger(subsystem: "io.github.akshatbaranwal.simple-caffeine", category: "launch-at-login")

    static var isEnabled: Bool {
        get {
            SMAppService.mainApp.status == .enabled
        }
        set {
            do {
                if newValue {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                log.error("Failed to toggle Launch at Login: \(String(describing: error), privacy: .public)")
            }
        }
    }
}
