# Contributing to Simple Caffeine

PRs welcome. This project is deliberately small — please keep it that way.

## Dev setup

```sh
brew install xcodegen
git clone https://github.com/akshatbaranwal/simple-caffeine.git
cd simple-caffeine
xcodegen generate
open SimpleCaffeine.xcodeproj
```

Hit `⌘R` to build and run. The app appears in the menu bar (LSUIElement, no Dock icon).

The `.xcodeproj` is `.gitignore`'d on purpose — it's generated from `project.yml` by [xcodegen](https://github.com/yonaskolb/XcodeGen). If you need to change project structure (sources, settings, deployment target), edit `project.yml` and regenerate.

## Project layout

```
SimpleCaffeine/
├── AppDelegate.swift              # entry point
├── MenuBarController.swift        # status item + menu items
├── CaffeineController.swift       # caffeinate process + Power Nap + ping
├── IconRenderer.swift             # the ☕ / ☕-with-✕ icons
├── DisclosureWindowController.swift  # "View What This Does" window
├── LaunchAtLogin.swift            # SMAppService wrapper
├── Info.plist                     # bundle metadata
└── Assets.xcassets/               # AppIcon set
```

`CaffeineController.swift` is the canonical source of truth for what the app actually does. The disclosure window (`DisclosureWindowController.swift`) duplicates that list in human-readable form for users. **If you change behavior in `CaffeineController.swift`, update the disclosure text to match.**

## What to PR

- Bug fixes
- macOS version compatibility
- Better icons / icon design
- Small features that fit the "simple and transparent" spirit
- v2 work: SMAppService privileged helper to remove the admin password prompt (see `README.md`)

## What not to PR

- Telemetry, analytics, or any data collection
- Auto-update or self-update logic (Homebrew handles updates)
- Settings UI for things that don't actually need toggling
- Dependencies (this app has none on purpose)

## Style

- Swift 5, AppKit (no SwiftUI for menu-bar code — AppKit is simpler here)
- No third-party Swift packages
- Keep files small; no need to break up further

## Reporting issues

If toggling fails on your Mac, please attach:

- macOS version (`sw_vers`)
- Output of `pmset -g custom`
- Anything relevant from Console.app filtered by `io.github.akshatbaranwal.simple-caffeine`
