# Changelog

## 1.1 (34), October 18, 2026

- 210 more stations in North America, for 459 stations in 13 countries. Every US city outside New York now has at least ten; Atlanta, Dallas–Fort Worth, Houston, Denver, Detroit, Nashville and San Diego get their first dials; and Canada joins with Toronto, Montreal and Vancouver. The picks come from the latest Nielsen and Numeris ratings, a few local favourites, and the stations each city's Reddit radio threads name most. See [North America expansion](docs/na-expansion.md).
- New FM dials for Paris, Madrid, Milan and Santiago, using stations Dial already had, so favorites still work. See [city dials](docs/city-dials.md).
- All Locations opens with the most-listened stations instead of dial order. A city or Favorites keeps dial order. See [All Locations ranking](docs/all-locations-ranking.md).
- Favorites sync between iPhone and Mac through your own iCloud account. Without iCloud they stay on the device.
- Now Playing on the Lock Screen and in Control Center shows the station's artwork.
- Building for iPhone with a free Apple account now means removing iCloud under Signing & Capabilities; see [Install](README.md#install).

## 1.0 (33), October 17, 2026

First public release.

- A radio tuner for iPhone and Mac: turn a dial through a city's real FM and AM frequencies, or browse 249 checked live stations from 12 countries by artwork or list.
- Live song and program titles when stations send them, with Apple Music, Spotify and Tidal search.
- Favorites, search by name, city or frequency, a sleep timer, spoken station announcements, Shortcuts actions, background playback, Now Playing and AirPlay.
- iPhone only: station alarms (iOS 26.1+), alternate app icons, haptics and keep-awake while charging.
- Mac: one native app from the same code, living in the menu bar. Click the radio icon to open the player; screens open inside it, and the radio keeps playing when it closes. A power button at the top of the player quits.
- One Stations screen for browsing and choosing a location. Its location filter lists each country's real dials (for example, New York metro) and starts with "Use my location". The dial always has a location; regions without stations start in New York. The player has one bottom button: it shows the current city and opens Stations there.
- No ads, accounts, analytics or servers of its own. "Use my location" asks only when tapped, checks that Location Services is on, and never stores the location.
- Mac download: a notarized DMG for macOS 14 or later.
