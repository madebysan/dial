# Dial overview

Every feature, what Dial doesn't do, release status and the documentation index. The short version is the [README](../README.md).

## What it does

- **A tactile tuner.** Drag the dial or skip between a city's stations. Feeds without a local frequency play in an artwork player.
- **249 checked stations in 12 countries:** the United States, United Kingdom (including the BBC's international directory), Uruguay, Argentina, Spain, Brazil, Mexico, Colombia, Chile, France, Italy and Japan.
- **Stations library** with artwork and list views, search by name, city or frequency, worldwide or per-city browsing, and favorites.
- **Live titles** when a station supplies them. Save a title, or look it up in Apple Music, Spotify or Tidal.
- **Listening tools:** a sleep timer, optional spoken station announcements, a quiet tuning sound, and Siri and Shortcuts actions. iPhone also has native station alarms (iOS 26.1+), alternate app icons, haptics and keep-awake while charging.
- **System playback:** background audio, Now Playing and media keys, AirPlay and output selection, and automatic reconnection after network drops.

## What it doesn't do

Dial has no ads, accounts, analytics or servers of its own. Streams play directly from each broadcaster, and broadcasters may include their own advertising. Some station logos load from the broadcaster's site. "Use my location" asks for approximate location only when you tap it, sends it to Apple's geocoding service (MapKit, or the older geocoder before iOS 26) to look up the country, and keeps only the country, never the location.

There's no recording, song recognition, podcast support or favorites sync between devices. Alarms ring through the system and offer **Play station**; they can't start internet radio on their own from a closed app.

## Status

Version 1.0 is distributed for Mac as a notarized download on [GitHub Releases](https://github.com/madebysan/dial/releases/latest). It is not on the App Store; iPhone users build it from source. One app with the same code runs on both: Mac secondary screens open inside the player window, and iPhone uses sheets.

## Documentation

- [Mac app](macos.md): how iPhone and Mac share code, the menu bar app, sandbox and release build
- [Settings](settings.md), [tuning locations](tuning-locations.md), [motion](motion.md) and [listening features](features-v25.md)
- Catalogue evidence: [expansion](catalog-expansion.md), [US](us-expansion.md), [UK and BBC](uk-expansion.md) and [gap fill](gap-fill.md)
