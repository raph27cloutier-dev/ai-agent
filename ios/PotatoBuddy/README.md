# Potato Buddy (iOS)

A standalone SwiftUI iPhone app version of Potato Buddy. Apple's sandboxing
doesn't allow any app to draw over other apps or the Home Screen (unlike the
macOS menu bar version, which floats above the Dock), so here the potato
lives and roams inside its own full-screen app.

It reuses the same pixel-art design and behavior state machine as the macOS
version (see `../../Sources/PotatoBuddy` at the repo root), adapted for
touch instead of mouse tracking:

- **Idle / walking**: wanders left and right near the bottom of the screen,
  blinking every few seconds.
- **Fleeing**: touch and hold near the potato (without touching it directly)
  and it'll scurry to the other side of the screen.
- **Draggable**: touch the potato itself and drag it around; lift your
  finger and it falls back down under simple gravity.

## Requirements

- A Mac with Xcode 15+ installed
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (`brew install xcodegen`)
  — used to generate the `.xcodeproj` from `project.yml` instead of
  hand-authoring Xcode's project file format

## Build & run

```sh
cd ios/PotatoBuddy
xcodegen generate
open PotatoBuddy.xcodeproj
```

Then in Xcode, pick an iPhone simulator (or your device) and hit Run (⌘R).

## Customizing

- `Sources/PotatoSprite.swift` — pixel grid, colors, expressions and leg
  poses (same layout as the macOS sprite, just using `Color` + `Canvas`
  instead of `NSColor` + `CGContext`).
- `Sources/PotatoViewModel.swift` — speeds, flee radius, timings, and the
  idle/walking/fleeing/dragging/falling state machine.
- `Sources/ContentView.swift` — the two gestures: one on the background to
  detect a nearby "poke", one on the potato itself for picking it up.
