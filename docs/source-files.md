# Dial source files

Which file owns what, and how to build and test. Build-and-install steps for your own device are in the [README](../README.md#install).

## Build and test

Open `Dial.xcodeproj` and run the Dial scheme on an iPhone, a simulator or **My Mac**. The Mac app shares every source file with the iPhone app; see [Mac app](macos.md). No external packages or API credentials are needed. `project.yml` is the XcodeGen configuration source.

```sh
xcodebuild -project Dial.xcodeproj -scheme Dial -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

## Ownership

- `DialApp.swift`: app entry, the shared player (`DialApp.sharedRadio`, also used by CarPlay), the iPhone window and the Mac menu bar extra.
- `Platform.swift`: the few iPhone/Mac differences and how secondary screens open.
- `RadioView.swift` / `TuningDial.swift`: the player screen, the dial and its frequency readout.
- `RadioSettings.swift` / `ListeningSettingsViews.swift`: Settings, narration, Shortcuts and the app icon picker.
- `DialMotion.swift`: shared motion values and Reduce Motion handling.
- `StationProfile.swift` / `StreamMetadata.swift`: decoded profiles and live stream titles.
- `TuningNoise.swift`: the quiet static played while a stream connects.
- `Station.swift`: decoded station model, country collections and band definitions.
- `Library.swift`: selection, favorites, local tuning scope and restoration.
- `RadioPlayer.swift`: AVPlayer, audio lifecycle, retries, timed metadata and Now Playing.
- `Preferences.swift`: appearance/layout, autoplay, haptics, narration, keep-awake preferences and the session sleep timer.
- `StationLibrary.swift`: worldwide/country/city browsing, the location filter, Use my location and first-launch station choice.
- `CountryLocation.swift`: explicit approximate-country lookup and permission/error handling.
- `FavoritesSync.swift`: the iCloud key-value store for favorites. `Library` owns the merge rules: a device's first sync and an account change merge; after that iCloud's list wins, so removals spread.
- `CarPlay.swift`: the CarPlay scene (Favorites, Dial and Locations tabs, then Now Playing with a favorite button).
- `ArtworkImages.swift`: station artwork as images for Now Playing and CarPlay, on Dial's light or dark tile.
- `RadioIntents.swift`: station entities, Shortcuts actions and the shared playback-command path.
- `StationAlarms.swift` / `StationAlarmsViews.swift`: native alarm scheduling, local records and alarm controls.
- `ListeningBehavior.swift`: foreground keep-awake policy and station narration.
- `SavedItems.swift` / `SavedItemsViews.swift`: local saved titles, music searches and sharing.
- `StationInfo.swift` / `Palette.swift`: station details actions and the distinct charcoal sheet surface.
- `scripts/check-streams.py`: resumable three-second audio decoding checks.
- `DialTests/LiveCatalogTests.swift`: explicit AVPlayer validation of the earlier 120 additions, a 24-feed US batch, a 78-feed UK/BBC review and the ten-station gap-fill batch, with a one-hour cache keyed by station ID and exact URL.
- `DialTests/` and `DialUITests/`: model, persistence, country browsing and playback checks. Tests requiring live audio need internet access. Use `-skip-testing:DialTests/LiveCatalogTests` for the ordinary suite; run that class when changing catalogue stream URLs.
