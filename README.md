# Potato Buddy

A tiny pixel-art potato that lives on your Mac's Dock — a menu bar app inspired
by the "desktop creatures" built with Claude Code. It idles, wanders back and
forth along the Dock, scurries away if your cursor gets too close, and can be
picked up and dropped by dragging.

The sprite is drawn procedurally (no image assets) from a small pixel grid
defined in `Sources/PotatoBuddy/PotatoSprite.swift`, so it's easy to reskin
into a different creature by changing the shapes/colors there.

## Requirements

- macOS 12+
- Xcode Command Line Tools (`xcode-select --install`) for the `swift` toolchain

This app uses AppKit (`Cocoa`), so it only builds and runs on macOS — it
can't be built or tested in a Linux environment.

## Run

```sh
swift run
```

This launches the app in the foreground of your terminal. Look for the 🥔
icon in the menu bar for controls (Show/Hide, Come Here, Quit). Press
Ctrl-C in the terminal to stop it.

## Build a standalone binary

```sh
swift build -c release
.build/release/PotatoBuddy &
```

## How it behaves

- **Idle / walking**: wanders left and right along the top edge of the Dock,
  pausing occasionally, blinking every few seconds.
- **Fleeing**: if your cursor gets close (and is roughly at Dock height), the
  potato panics and runs the other way.
- **Draggable**: click and drag to pick it up; release to drop it — it falls
  back down to the Dock.
- Runs as an accessory app (no Dock icon, no app-switcher entry) — only the
  menu bar icon shows.

## Customizing

- `PotatoSprite.swift` — pixel grid, colors, expressions (normal/blink/
  scared/surprised) and leg poses.
- `CreatureController.swift` — speeds, flee radius, timings, and the
  idle/walking/fleeing/dragging/falling state machine.
- `CreatureWindow.swift` — window level/behavior (e.g. change `.floating` to
  `.screenSaver` if you want it to float above full-screen apps too).
