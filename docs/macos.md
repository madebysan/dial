# Mac app

Dial runs natively on macOS from the **same target, files, bundle ID and version** as the iPhone app. Nothing is forked. `project.yml` lists both platforms under `supportedDestinations: [iOS, macOS]`. Choose the *My Mac* run destination in Xcode, or build from Terminal:

```sh
xcodebuild -project Dial.xcodeproj -scheme Dial -destination 'platform=macOS' build
```

This is native SwiftUI on macOS 14 or later, not Mac Catalyst and not the iPad app running on Apple silicon.

## How the shared code splits

`Dial/Platform.swift` collects the small system differences behind one name each: colors, images, haptics, VoiceOver state, navigation-title style and the leading toolbar slot. The remaining `#if os(…)` branches stay next to the feature they affect:

| Area | iPhone | Mac |
|---|---|---|
| Audio session, interruptions, unplugged-headphone pause | `AVAudioSession` | Not needed; macOS routes audio itself |
| Audio output button | `AVRoutePickerView` (UIKit) | `AVRoutePickerView` (AppKit) |
| Now Playing | Info dictionary | Info dictionary plus explicit `playbackState` |
| Headphones-only announcements | Audio-session route | Default output device: Bluetooth transport or the headphone data source |
| Station alarms | AlarmKit, iOS 26.1+ | Hidden; AlarmKit does not exist on macOS |
| App icon picker | Alternate icons | Hidden |
| Haptics, keep awake while charging | Settings toggles | Hidden |
| Siri tip and Shortcuts button | `SiriTipView`, `ShortcutsLink` | An Open Shortcuts link; the three actions still appear in Shortcuts |
| Player menus and live title | Plain text controls | Same look, via `plainMenuLabel()` and `.borderless`; macOS otherwise draws bordered pop-up and push buttons |
| Location lookup | MapKit on iOS 26+, older geocoder below | Same, on macOS 26+ |

## Menu bar app

- Dial is a **menu bar app**: a radio icon in the menu bar (filled while playing) and no Dock icon (`LSUIElement`). Clicking the icon opens the player in a 400 × 720 pt panel (a SwiftUI `MenuBarExtra` with the window style); clicking elsewhere closes it and the radio keeps playing.
- With no Dock icon or menus, a **power button** at the end of the player's top icon row quits Dial (⌘Q while the panel is open).
- Media keys and Now Playing still control playback with the panel closed. The Playback commands (⌘P, ⌘→, ⌘←) remain defined but have no visible menu.

## Screens open in the window

The iPhone presents secondary screens as sheets. On Mac they open **inside the player panel**: Stations, Settings, station details and Now playing (from the live title). Each one slides over the player and closes with a back arrow, or with Esc. Deeper pages push in the same panel with the system back button. These include station details from Stations, the Settings subpages and saved titles. The only Mac sheet is the small Use my location status panel, attached to the player while the country lookup runs.

The shared pieces are in `Platform.swift`:

- `ScreenStack` gives a screen its own navigation stack, or pushes it into the presenting screen's stack on Mac.
- `@ScreenDismiss` dismisses an iPhone sheet or returns to the Mac player.
- `ScreenCloseItem` is the iPhone's Done button or the Mac back arrow.
- `.screen(item:)` and `.screen(isPresented:)` are sheets on iPhone and pushes on Mac.

The player stays alive underneath, hidden from clicks and VoiceOver.

Mac-specific layout fixes:

- Grouped forms replace the default two-column Mac form layout.
- Form buttons are text rows.
- Settings-style lists use grouped forms, with right-click Delete for saved titles.
- Plain lists get edge insets, and country rows get disclosure arrows.
- The grid/list toggle sits on the trailing side of the title bar.
- Copy says Click and System Settings instead of Tap and iPhone Settings.

## App icon

The Mac uses the same `AppIcon` set and the same knob artwork as the iPhone. `scripts/make-mac-icons.swift` turns `icon.png` into the ten Mac sizes. It places the artwork in Apple's Mac icon grid: an 824 px rounded square with a soft shadow on a transparent 1024 px canvas. iPhone still uses the untouched full-bleed original. If `icon.png` changes, rerun:

```sh
swift scripts/make-mac-icons.swift Dial/Assets.xcassets/AppIcon.appiconset
```

The three alternate icons are iPhone-only build settings.

## Sandbox

The Mac build is sandboxed through `Dial/Dial-macOS.entitlements`, which applies only to macOS. It grants outgoing network access (streams, artwork, metadata) and location (Use my location). `NSLocationUsageDescription` supplies the Mac permission text.

## Release build (GitHub DMG)

Dial for Mac is distributed as a notarized DMG on GitHub Releases, not through the App Store.

1. Archive the Release Mac build with `xcodebuild archive … -destination 'generic/platform=macOS' -allowProvisioningUpdates`.
2. Export it with `method: developer-id` (team QAMM2A6WRQ) so it is signed as **Developer ID Application**. Hardened runtime is enabled for macOS only.
3. Zip the app, notarize it with `xcrun notarytool submit … --keychain-profile notarytool --wait`, then `xcrun stapler staple` the app.
4. Stage a DMG containing `Dial.app`, an Applications link, `README.md` and `LICENSE`, with the app icon as the volume icon.
5. Sign the DMG, notarize it the same way, staple it, and confirm `spctl --assess --type open --context context:primary-signature` reports "Notarized Developer ID".

1.0 (33) was built this way on October 17, 2026: `Dial-1.0.dmg`, 8.1 MB, SHA-256 `bb9f30a330b8126b6a74f19397bbc7840ca0b6e353b8ad4514b6363a9ea6ab19`. Both the app and the DMG were accepted by notarization and pass Gatekeeper.

## App Store (not pursued)

Build 1.0 (32) was submitted to the App Store for iPhone and Mac in October 2026. App Review rejected the Mac version, mainly under Guideline 5.2.3, which requires documented permission from broadcasters to stream their stations. Dial is therefore distributed for Mac as a notarized download instead, and iPhone users build it from source.

## Tests

`DialTests` runs on both platforms. The keep-awake test is iPhone-only. Mac test runs, and Debug launches with `--muted`, start silent because the unit tests host the real app. Normal Mac launches use normal volume. `DialUITests` remains iPhone-only.
