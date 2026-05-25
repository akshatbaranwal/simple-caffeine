import Cocoa

final class DisclosureWindowController {
    private var window: NSWindow?

    func show() {
        if let existing = window {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let contentRect = NSRect(x: 0, y: 0, width: 620, height: 520)
        let window = NSWindow(
            contentRect: contentRect,
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "What Simple Caffeine Does"
        window.center()
        window.isReleasedWhenClosed = false

        let scrollView = NSScrollView(frame: contentRect)
        scrollView.hasVerticalScroller = true
        scrollView.autoresizingMask = [.width, .height]
        scrollView.borderType = .noBorder

        let textView = NSTextView(frame: contentRect)
        textView.isEditable = false
        textView.isSelectable = true
        textView.font = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        textView.textContainerInset = NSSize(width: 18, height: 18)
        textView.string = Self.disclosureText
        textView.autoresizingMask = [.width]
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.textContainer?.widthTracksTextView = true

        scrollView.documentView = textView
        window.contentView = scrollView

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    private static let disclosureText = """
    Simple Caffeine — what runs when you click the menu bar icon

    This app is intentionally simple and transparent. Below is the exact list
    of commands it runs on your Mac. Nothing else. No analytics, no telemetry,
    no auto-update, no background services beyond the ones listed here.

    WHEN YOU TURN CAFFEINE ON
    -------------------------
    1. Read your current Power Nap settings (no admin needed):
         /usr/bin/pmset -g custom

    2. Save those values, then disable Power Nap for both power sources.
       This requires admin; macOS shows a password prompt:
         sudo /usr/bin/pmset -c powernap 0
         sudo /usr/bin/pmset -b powernap 0

    3. Start the caffeinate process to block sleep:
         /usr/bin/caffeinate -dimus

    4. Every 30 seconds, send a background HEAD request to Cloudflare's DNS
       to keep the WiFi connection from idling out:
         HEAD https://1.1.1.1

    WHEN YOU TURN CAFFEINE OFF
    --------------------------
    1. Terminate the caffeinate process.

    2. Stop the 30-second keep-alive timer.

    3. Restore your saved Power Nap settings (admin prompt may appear):
         sudo /usr/bin/pmset -c powernap <your-saved-value>
         sudo /usr/bin/pmset -b powernap <your-saved-value>

    STATE PERSISTENCE
    -----------------
    The only data Simple Caffeine stores is your original Power Nap values,
    saved in:
      ~/Library/Preferences/io.github.akshatbaranwal.simple-caffeine.plist

    On reboot, Simple Caffeine always starts in the OFF state.

    WHY THE WIFI PING?
    ------------------
    Some routers and corporate networks idle out WiFi clients that haven't sent
    traffic in a few minutes. The 30-second keep-alive prevents that. It is a
    background HEAD request to 1.1.1.1 — no DNS lookup, no payload, no logs.
    If you'd rather not, the app's source is open; remove the timer in
    CaffeineController.swift and rebuild.

    SOURCE CODE
    -----------
    https://github.com/akshatbaranwal/simple-caffeine

    The file CaffeineController.swift is the canonical source of truth for
    what this app actually runs. If anything above disagrees with that file,
    the file wins.
    """
}
