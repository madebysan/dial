# Listening features and country setup

Approved feature batch, October 10, 2026. The four earlier exclusions remain: weather, rewind, CarPlay and automatic Shazam.

Introduced in build 25 and included in current installed build 31. Locations now opens country → city/metro or Other stations, with plain station counts and a simple Use my location row. Approximate lookup opens a country’s choices rather than selecting a station. [Tuning locations](tuning-locations.md) owns the current navigation contract; verification owns installed-build and test status.

## Behavior and ownership

| Feature | Intended behavior | Owner / verification |
|---|---|---|
| First-launch country | Restore a valid saved station first. Otherwise choose a supported iPhone Region; if unsupported, ask for a country before autoplay. A manual choice persists. | Library; startup and restoration tests |
| Use my location | Explicit Use my location row. Request When In Use with reduced accuracy when needed, resolve a supported country once, then open its location choices. Manual fallback for denial, failure or missing coverage. No coordinates stored. | CountryLocation; permission and country-selection checks |
| Keep awake | Off by default. When enabled, disable idle sleep only while Dial is in the foreground and the device is charging/full. Restore normal idle behavior otherwise. | ListeningBehavior; pure policy and lifecycle checks |
| Haptics | On by default to preserve current feedback. The toggle controls Dial's tuning, favorite and station-selection haptics. | Preferences and views |
| Narration | Off by default. Optional station-change announcements for headphones/Bluetooth or all outputs, with system/installed voice selection. Lower stream volume during speech; do not duplicate VoiceOver. | StationNarrator and RadioPlayer |
| Shortcuts | Play a selected station, resume Dial, and pause. Suggest favorites; route all requests through one app command path. | RadioIntents; entity and command tests |
| Station alarms | iOS 26.1+: native AlarmKit alarm, one-time/daily/weekdays scheduling, permission on explicit creation, delete/cancel support. The alarm rings natively and offers Play station. A closed app is not promised to begin an internet stream without user interaction. | StationAlarms and App Intent; schedule/cancel/device availability checks |
| Saved songs/titles | Save exactly the current supplied title with station/date. Avoid exact duplicate titles. Remove saved items; open Apple Music, Spotify or Tidal searches. No song recognition or service-account writes. | SavedItems; persistence/deduplication/URL tests |
| Alternate icons | Use the four already generated options. OS icon choice is authoritative; default remains the selected metal knob. | IconPicker; compiled icon dictionaries and selection checks |
| Share / report station | Native sharing of station name and public listening/source link. Reports are saved on-device and can be shared explicitly; no fictitious server or automatic email. **Reports removed after build 31** (local-only, never reached anyone); sharing remains. | StationInfo and SavedItems/report views |

Favorites sync remains a separate, unapproved implementation choice; the inspected development profile has no iCloud entitlement. No iCloud account configuration or upload is authorized by the local-feature implementation alone.

## Delivery

Keep the three-control player header, selected icon, pure-black dark theme and existing catalog. Additional controls belong in station details and Settings subpages, not a crowded player toolbar. Add permissions only for the implemented actions. Preserve existing favorites, last station, appearance, autoplay and sleep-timer behavior. No new service credentials or paid generations are needed for the local features.

Use existing model/UI tests plus focused new coverage. Keep simulator audio muted and clean up test-created alarms. Device-only behavior and second-device sync must be distinguished from simulated verification. Do not change real user preferences, create real alarms or invoke sharing on the user's behalf during installation.

## Verification at introduction and remaining limits

Build 25 was installed and has since been superseded by build 31. The 39 model checks and 9 distinct UI scenarios passed across the final relevant runs. Native checks covered country choice/restoration, approximate-location permission and resolution using a simulated public New York coordinate, live-title saving, AlarmKit creation/cancellation/deletion, icon switching/restoration, report persistence, playback commands and existing Settings/appearance behavior. Test alarms were scheduled one hour ahead and removed before they could ring. See verification for run summaries, corrected findings and limits.

The alarm alert action, Siri voice invocation, audible narration over real Bluetooth/headphones, and hardware charging transitions still require physical-device use. No alarm was created on san's iPhone during verification. Music links open searches rather than writing to service playlists. Reports stay local until san chooses a share destination.
