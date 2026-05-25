# Simple Caffeine

A small, transparent macOS menu bar app that keeps your Mac awake. One click to toggle.

- Filled coffee cup in the menu bar means caffeine is **on** (your Mac will not sleep).
- Coffee cup with a red ✕ means caffeine is **off** (normal sleep behavior).

That's the whole app.

## Why "simple"

- No analytics, no telemetry, no auto-update, no daemons.
- One `caffeinate` subprocess, one keep-alive ping every 30 seconds, and an admin prompt the first time you toggle (to manage Power Nap).
- The menu has a **View What This Does…** item that shows the literal list of commands the app runs. You can also read the source — it's about 300 lines of Swift.

## Install

Via Homebrew (recommended):

```sh
brew tap akshatbaranwal/tap
brew install --cask simple-caffeine
```

Manual install:

1. Download the latest `SimpleCaffeine-<version>.zip` from the [Releases page](https://github.com/akshatbaranwal/simple-caffeine/releases).
2. Unzip and drag `SimpleCaffeine.app` to `/Applications/`.
3. The app is not signed with an Apple Developer ID yet, so the first launch will be blocked by Gatekeeper. Right-click the app and choose **Open**, or run `xattr -d com.apple.quarantine /Applications/SimpleCaffeine.app` once.

## What it does

When you turn caffeine **on**, the app:

1. Reads your current Power Nap settings via `pmset -g custom`.
2. Saves those values, then disables Power Nap on both AC and battery via `sudo pmset -c powernap 0` and `sudo pmset -b powernap 0`. macOS prompts for your password the first time per session.
3. Starts `caffeinate -dimus` to block display, idle, system, and disk sleep.
4. Begins a 30-second background HEAD request to `https://1.1.1.1` to keep WiFi from idling out on networks that idle out quiet clients.

When you turn it **off**, the app terminates `caffeinate`, stops the keep-alive timer, and restores your saved Power Nap settings.

On reboot, the app always starts in the off state.

## Build from source

Requirements: macOS 13+, Xcode 15+, [xcodegen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`).

```sh
git clone https://github.com/akshatbaranwal/simple-caffeine.git
cd simple-caffeine
xcodegen generate
open SimpleCaffeine.xcodeproj
```

Then `⌘R` in Xcode. Or build from the command line:

```sh
./Scripts/build-release.sh
open build/Release/SimpleCaffeine.app
```

## Contributing

Pull requests welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

[MIT](LICENSE) — fork it, ship it, sell it. Just don't blame me.
