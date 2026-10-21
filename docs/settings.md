# Settings

## Initial additions · build 24

- **Play when opening:** persist a Boolean preference, defaulting to on so existing installations keep their behavior. When off, launch and foreground activation do not start audio. It does not stop audio already playing or block explicit Play, station, band or country selection. Sleep-timer expiry continues to suppress automatic playback until playback is explicitly restarted.
- **About:** show the actual bundle version/build, link Radio Browser as a catalogue research source, and point users to station profiles for broadcaster/artwork evidence. No account, analytics or new external service is added.

Existing appearance, tuning sound and sleep timer remain available. Build 25 adds country setup and an explicit location action in Locations; see below.

## Listening additions · build 25

Appearance includes App icon with tuning knob (default), monogram, signal and pocket radio. Playback adds Haptic feedback (on by default), Keep awake while charging (off), and Station announcements (off). Announcements can use headphones/Bluetooth or all outputs with a system/installed voice; VoiceOver takes priority.

Listening contains Station alarms and Siri & Shortcuts. Alarms require iOS 26.1+ and explicit permission when first saving. Choose a station, time and once/every-day/weekdays repeat. The system alarm offers Play station to open Dial; automatic streaming from a closed app is not promised. Swipe an alarm to delete it. The three Shortcuts actions are Play station, Play Dial and Pause Dial.

Library contains Saved titles. Tap a supplied title in the player to save it or open a music-service search. No account integration is present. Station reports were removed after build 31: they were only saved on the device and never reached anyone.

[Full behavior and implementation scope](features-v25.md) · Verification and limitations
