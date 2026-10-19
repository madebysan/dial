# Dial overview

Every feature, what Dial doesn't do, release status and the documentation index. The short version is the [README](../README.md).

## What it does

- **A tactile tuner.** Drag the dial or skip between a city's stations. Feeds without a local frequency play in an artwork player.
- **459 checked stations in 13 countries:** the United States (22 cities), Canada (Toronto, Montreal and Vancouver), United Kingdom (including the BBC's international directory), Uruguay, Argentina, Spain, Brazil, Mexico, Colombia, Chile, France, Italy and Japan.
- **Stations library** with artwork and list views, search by name, city or frequency, worldwide or per-city browsing, and favorites that sync through the person's own iCloud account.
- **Live titles** when a station supplies them. Save a title, or look it up in Apple Music, Spotify or Tidal.
- **Listening tools:** a sleep timer, optional spoken station announcements, a quiet tuning sound, and Siri and Shortcuts actions. iPhone also has native station alarms (iOS 26.1+), alternate app icons, haptics and keep-awake while charging.
- **System playback:** background audio, Now Playing with station artwork and media keys, AirPlay and output selection, and automatic reconnection after network drops.
- **CarPlay (built, not yet usable in a car):** Favorites, the playing station's dial and every location, then the system Now Playing screen. It runs in the Simulator's CarPlay window; a real car needs Apple to grant Dial the CarPlay audio entitlement.

## What it doesn't do

Dial has no ads, accounts, analytics or servers of its own. Streams play directly from each broadcaster, and broadcasters may include their own advertising. Some station logos load from the broadcaster's site. "Use my location" asks for approximate location only when you tap it, sends it to Apple's geocoding service (MapKit, or the older geocoder before iOS 26) to look up the country, and keeps only the country, never the location.

Favorites sync through iCloud key-value storage in the person's own iCloud account; Dial runs no server and never sees them. There's no recording, song recognition or podcast support. Alarms ring through the system and offer **Play station**; they can't start internet radio on their own from a closed app.

## Status

Version 1.0 is distributed for Mac as a notarized download on [GitHub Releases](https://github.com/madebysan/dial/releases/latest). It is not on the App Store; iPhone users build it from source. One app with the same code runs on both: Mac secondary screens open inside the player window, and iPhone uses sheets.

## Documentation

- [Mac app](macos.md): how iPhone and Mac share code, the menu bar app, sandbox and release build
- [Settings](settings.md), [tuning locations](tuning-locations.md), [motion](motion.md) and [listening features](features-v25.md)
- Catalogue evidence: [expansion](catalog-expansion.md), [US](us-expansion.md), [UK and BBC](uk-expansion.md), [gap fill](gap-fill.md) and [city dials](city-dials.md)
