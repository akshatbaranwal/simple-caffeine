import Foundation
import os.log

final class CaffeineController {
    private(set) var isActive: Bool = false
    private var caffeinateProcess: Process?
    private var pingTimer: Timer?

    private let defaults = UserDefaults.standard
    private let acKey = "savedAcPowerNap"
    private let battKey = "savedBattPowerNap"
    private let log = Logger(subsystem: "io.github.akshatbaranwal.simple-caffeine", category: "caffeine")

    var onStateChange: (() -> Void)?

    func toggle() {
        isActive ? stop() : start()
    }

    func start() {
        guard !isActive else { return }
        saveAndDisablePowerNap()
        startCaffeinate()
        startPingTimer()
        isActive = true
        onStateChange?()
    }

    func stop() {
        guard isActive else { return }
        stopCaffeinate()
        stopPingTimer()
        restorePowerNap()
        isActive = false
        onStateChange?()
    }

    func shutdown() {
        if isActive { stop() }
    }

    // MARK: - caffeinate subprocess

    private func startCaffeinate() {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        process.arguments = ["-dimus"]
        process.standardOutput = FileHandle.nullDevice
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            caffeinateProcess = process
        } catch {
            log.error("Failed to start caffeinate: \(String(describing: error), privacy: .public)")
        }
    }

    private func stopCaffeinate() {
        caffeinateProcess?.terminate()
        caffeinateProcess?.waitUntilExit()
        caffeinateProcess = nil
    }

    // MARK: - Power Nap toggling (per power source)

    /// Reads the current `powernap` value for the given pmset section.
    /// `source` is either "AC Power:" or "Battery Power:".
    private func currentPowerNap(source: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "custom"]
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice
        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let output = String(data: data, encoding: .utf8) else { return nil }

        var inSection = false
        for rawLine in output.split(separator: "\n", omittingEmptySubsequences: false) {
            let line = String(rawLine)
            if line.hasPrefix(source) {
                inSection = true
                continue
            }
            if inSection {
                if line.first?.isLetter == true && !line.hasPrefix(" ") {
                    inSection = false
                    continue
                }
                if line.contains("powernap") {
                    let parts = line.split(separator: " ", omittingEmptySubsequences: true)
                    if let last = parts.last {
                        return String(last)
                    }
                }
            }
        }
        return nil
    }

    private func saveAndDisablePowerNap() {
        let ac = currentPowerNap(source: "AC Power:")
        let batt = currentPowerNap(source: "Battery Power:")
        if let ac = ac { defaults.set(ac, forKey: acKey) }
        if let batt = batt { defaults.set(batt, forKey: battKey) }

        var commands: [String] = []
        if ac != nil { commands.append("/usr/bin/pmset -c powernap 0") }
        if batt != nil { commands.append("/usr/bin/pmset -b powernap 0") }
        guard !commands.isEmpty else { return }
        runAsAdmin(commands.joined(separator: "; "))
    }

    private func restorePowerNap() {
        let savedAc = defaults.string(forKey: acKey)
        let savedBatt = defaults.string(forKey: battKey)
        var commands: [String] = []
        if let value = savedAc { commands.append("/usr/bin/pmset -c powernap \(value)") }
        if let value = savedBatt { commands.append("/usr/bin/pmset -b powernap \(value)") }
        guard !commands.isEmpty else { return }
        runAsAdmin(commands.joined(separator: "; "))
        defaults.removeObject(forKey: acKey)
        defaults.removeObject(forKey: battKey)
    }

    private func runAsAdmin(_ shellCommand: String) {
        let escaped = shellCommand
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
        let script = "do shell script \"\(escaped)\" with administrator privileges"
        var errorInfo: NSDictionary?
        let appleScript = NSAppleScript(source: script)
        appleScript?.executeAndReturnError(&errorInfo)
        if let error = errorInfo {
            log.error("AppleScript admin call failed: \(error, privacy: .public)")
        }
    }

    // MARK: - WiFi keep-alive

    private func startPingTimer() {
        pingCloudflare()
        pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            self?.pingCloudflare()
        }
    }

    private func stopPingTimer() {
        pingTimer?.invalidate()
        pingTimer = nil
    }

    private func pingCloudflare() {
        guard let url = URL(string: "https://1.1.1.1") else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        request.httpMethod = "HEAD"
        let task = URLSession.shared.dataTask(with: request) { _, _, _ in }
        task.resume()
    }
}
