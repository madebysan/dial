# Listening features and country setup

Approved feature batch, October 10, 2026. The earlier exclusions remain: weather, rewind and automatic Shazam. CarPlay was added later, on October 18, 2026.

Introduced in build 25 and current in 1.0 (33). Use my location now lives in the Stations location filter and shows the detected country's main city. [Tuning locations](tuning-locations.md) owns the current navigation contract; verification owns build and test status.

## Behavior and ownership

| Feature | Intended behavior | Owner / verification |
|---|---|---|
| First-launch country | Restore a valid saved station first. Otherwise choose a supported iPhone Region; if unsupported, start on WNYC in New York metro. A manual choice persists. | Library; startup and restoration tests |
| Use my location | First item in the Stations location filter. Request When In Use with reduced accuracy when needed, resolve a supported country once, then filter Stations to that country's main city (the default station's, else the dial with the most stations). Problems stay in a small sheet with Try Again; manual selection remains. No coordinates stored. | CountryLocation and StationLibrary; permission and country-selection checks |
| Keep awake | Off by default. When enabled, disable idle sleep only while Dial is in the foreground and the device is charging/full. Restore normal idle behavior otherwise. | ListeningBehavior; pure policy and lifecycle checks |
| Haptics | On by default to preserve current feedback. The toggle controls Dial's tuning, favorite and station-selection haptics. | Preferences and views |
| Narration | Off by default. Optional station-change announcements for headphones/Bluetooth or all outputs, with system/installed voice selection. Lower stream volume during speech; do not duplicate VoiceOver. | StationNarrator and RadioPlayer |
| Shortcuts | Play a selected station, resume Dial, and pause. Suggest favorites; route all requests through one app command path. | RadioIntents; entity and command tests |
| Station alarms | iOS 26.1+: native AlarmKit alarm, one-time/daily/weekdays scheduling, permission on explicit creation, delete/cancel support. The alarm rings natively and offers Play station. A closed app is not promised to begin an internet stream without user interaction. | StationAlarms and App Intent; schedule/cancel/device availability checks |
| Saved songs/titles | Save exactly the current supplied title with station/date. Avoid exact duplicate titles. Remove saved items; open Apple Music, Spotify or Tidal searches. No song recognition or service-account writes. | SavedItems; persistence/deduplication/URL tests |
| Alternate icons | Use the four already generated options. OS icon choice is authoritative; default remains the selected metal knob. | AppIconPicker (iPhone only); compiled icon dictionaries and selection checks |
| Share station | Native sharing of station name and public listening/source link. Station reports were removed after build 31 (local-only, they never reached anyone). | StationInfo |

Favorites sync was added separately on October 18, 2026, through iCloud key-value storage; see the development record.

## Delivery

Keep the three-control player header, selected icon, pure-black dark theme and existing catalog. Additional controls belong in station details and Settings subpages, not a crowded player toolbar. Add permissions only for the implemented actions. Preserve existing favorites, last station, appearance, autoplay and sleep-timer behavior. No new service credentials or paid generations are needed for the local features.

Use existing model/UI tests plus focused new coverage. Keep simulator audio muted and clean up test-created alarms. Device-only behavior and second-device sync must be distinguished from simulated verification. Do not change real user preferences, create real alarms or invoke sharing on the user's behalf during installation.

## Verification at introduction and remaining limits

At introduction in build 25, 39 model checks and 9 distinct UI scenarios passed across the final relevant runs. Native checks covered country choice/restoration, approximate-location permission and resolution using a simulated public New York coordinate, live-title saving, AlarmKit creation/cancellation/deletion, icon switching/restoration, playback commands and existing Settings/appearance behavior. Test alarms were scheduled one hour ahead and removed before they could ring. Verification has the current build's checks.

The alarm alert action, Siri voice invocation, audible narration over real Bluetooth/headphones, and hardware charging transitions still require physical-device use. No alarm was created on san's iPhone during verification. Music links open searches rather than writing to service playlists.
