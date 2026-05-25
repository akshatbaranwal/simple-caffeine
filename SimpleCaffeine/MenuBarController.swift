import Cocoa

final class MenuBarController {
    private let statusItem: NSStatusItem
    private let caffeineController = CaffeineController()
    private let disclosureWindow = DisclosureWindowController()
    private let onIcon = IconRenderer.makeCupIcon(crossed: false)
    private let offIcon = IconRenderer.makeCupIcon(crossed: true)

    init() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        setupButton()
        caffeineController.onStateChange = { [weak self] in
            self?.updateIcon()
        }
        updateIcon()
    }

    func shutdown() {
        caffeineController.shutdown()
    }

    private func setupButton() {
        guard let button = statusItem.button else { return }
        button.action = #selector(handleClick(_:))
        button.target = self
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        if let event = NSApp.currentEvent, event.type == .rightMouseUp {
            showMenu()
        } else {
            caffeineController.toggle()
        }
    }

    private func updateIcon() {
        guard let button = statusItem.button else { return }
        button.image = caffeineController.isActive ? onIcon : offIcon
        button.imagePosition = .imageOnly
    }

    private func showMenu() {
        let menu = NSMenu()

        let toggleTitle = caffeineController.isActive ? "Turn Off Caffeine" : "Turn On Caffeine"
        let toggleItem = NSMenuItem(title: toggleTitle, action: #selector(toggle), keyEquivalent: "")
        toggleItem.target = self
        menu.addItem(toggleItem)

        menu.addItem(.separator())

        let disclosureItem = NSMenuItem(title: "View What This Does…", action: #selector(showDisclosure), keyEquivalent: "")
        disclosureItem.target = self
        menu.addItem(disclosureItem)

        let githubItem = NSMenuItem(title: "Source Code on GitHub…", action: #selector(openGitHub), keyEquivalent: "")
        githubItem.target = self
        menu.addItem(githubItem)

        menu.addItem(.separator())

        let launchItem = NSMenuItem(title: "Launch at Login", action: #selector(toggleLaunchAtLogin), keyEquivalent: "")
        launchItem.target = self
        launchItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menu.addItem(launchItem)

        menu.addItem(.separator())

        let aboutItem = NSMenuItem(title: "About Simple Caffeine", action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)

        let quitItem = NSMenuItem(title: "Quit Simple Caffeine", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
        statusItem.button?.performClick(nil)
        statusItem.menu = nil
    }

    @objc private func toggle() {
        caffeineController.toggle()
    }

    @objc private func showDisclosure() {
        disclosureWindow.show()
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/akshatbaranwal/simple-caffeine") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func toggleLaunchAtLogin() {
        LaunchAtLogin.isEnabled.toggle()
    }

    @objc private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(nil)
    }

    @objc private func quit() {
        NSApp.terminate(nil)
    }
}
