# Dial behavior and catalogue

How the player, Stations and the catalogue behave in the current release. The [README](../README.md) is the short overview; [source files](source-files.md) maps each behavior to its code.

A native iPhone and Mac radio app with a tactile tuner and an artwork grid. The catalogue has **469 stations across thirteen country collections**, with worldwide browsing inside Stations.

| Collection | Stations |
|---|---:|
| United States | 238 |
| Canada | 28 |
| Uruguay | 24 |
| Argentina | 11 |
| Spain | 12 |
| Brazil | 10 |
| Mexico | 10 |
| Colombia | 10 |
| Chile | 10 |
| United Kingdom · BBC and UK feeds | 84 |
| France | 12 |
| Italy | 10 |
| Japan | 10 |

These are curated starter selections, not national audience rankings. The first US expansion adds 24 feeds across twelve markets beyond the original New York area, with a focus on public news, music discovery, jazz and classical music. See the [US expansion record](us-expansion.md). The [North America expansion](na-expansion.md) brings every US city outside New York to ten stations, adds seven US cities and adds Canada, with at least eight stations per dial. The [UK expansion](uk-expansion.md) covers the BBC’s 66-feed international directory plus a selection of other UK services. The UK collection includes the BBC’s Channel Islands services; their profile locations identify the islands accurately. The [Montevideo expansion](montevideo-expansion.md) adds ten stations to the Montevideo dial from the 2025 local ratings.

## Use

Light mode uses a neutral gray canvas and white artwork tiles. Dark mode uses a pure-black player canvas with neutral gray surfaces and text. Station details use a slightly lighter charcoal sheet, with lighter inset cards, to separate the sheet from the player. The silver play/pause control echoes the selected tuning-knob app icon; its dark glyph remains readable in both appearances. Tuner markers and selected-state accents are monochrome. Station artwork retains its original colors; white tiles separate white-backed logos from the surrounding grid.

The bottom row is one centered button: the list icon and, for FM/AM, the active city or metro on one line, truncating long names with an ellipsis. Country and station counts remain in the accessibility description. Tapping it opens Stations filtered to that city or metro. Stations without a listed local frequency use the country-wide Other stations group. Volume, settings and audio output form one centered row at the top, with no wordmark or Favorites shortcut; on Mac the row adds a power button that quits. Tap the speaker to adjust volume in a popover; the slider stays off the main player. When paused, the play button communicates the state without a separate Paused label. Dial movement and previous/next follow the visible location and band. Stations with the same frequency, including online feeds, sort naturally by name. Tap Stations to browse artwork or switch to the frequency list. Tap a station to open its player and start playback. Grid tiles have no star/info row; save favorites from station details, or use the list’s direct favorite action.

Tap the player’s frequency number, artwork or station name to open its details sheet. The FM/AM control remains a separate mode menu. Add/Remove favorite is at the top of that sheet; the player no longer has inline star/info icons. The name remains an entry point for AM/FM stations without artwork and is disabled during a tuning preview. Saving any inspected station does not change playback. Open Stations → Favorites to browse saved stations. Summary, format, language and website stay visible; verification notes and sources remain under Sources & stream details.

FM/AM player location appears in the selector instead of repeating it beneath the station name; online feeds retain meaningful broadcaster-city context. Live program/song titles appear when supplied; generic genre descriptions stay in station details. Visible status text is reserved for connecting, connection errors and the tuning gesture. Cadena 3 uses the sharper original broadcaster wordmark instead of its favicon.

Within Stations, **All Locations** shows all 469 stations worldwide, regardless of the playing station's country, most-listened first (see [All Locations ranking](all-locations-ranking.md)); a city keeps dial order. Search covers this collection in both layouts. The location menu starts with Use my location, then groups each country's city/metro dials and Other stations under country submenus; there is no country-wide entry. Worldwide list rows show country and city so reused frequencies stay distinct; the closed filter names the active city or metro. The filter and count share a row when they fit. Single-city results omit repeated location labels; metro, worldwide and favorite results retain them. Location filters apply within the open library; the player button opens the current dial location, and All Locations widens it. Search hides only when Favorites has no saved stations and no active query. See [tuning locations](tuning-locations.md). Tuning continues to follow the playing station's local band.

Local AM/FM entries retain the tuning dial. National or online feeds without a verified local frequency use an artwork player. Previous/next follows the current local band or online collection. Country selection and favorites persist across launches; original station IDs were preserved during expansion.

All streams are live. The mode menu labels feeds without a verified AM/FM frequency **Other stations**, matching the Stations location filter. This does not imply that a broadcaster has no terrestrial frequencies elsewhere. The stored catalogue value remains unchanged for compatibility.

The player supports live broadcaster titles when supplied, volume, audio routing, background playback, system Now Playing controls, connection retries, and recovery after a network outage. Play after pause reconnects to the live feed. A quiet tuning sound is optional. Settings includes system/light/dark appearance, a persistent Play when opening toggle, and 15/30/45/60-minute sleep timers. Autoplay defaults to on; when off, reopening the app stays silent until an explicit playback action. About shows the current version/build and catalogue credits. See [Settings behavior](settings.md). While a timer runs, its presets are under Change duration; countdown and cancellation remain visible. A completed timer suppresses foreground autoplay until playback is explicitly restarted. Timers do not survive force quit.

Settings also includes optional haptics, keeping the screen awake while charging, spoken station announcements with voice selection, three Siri/Shortcuts actions, native station alarms on iOS 26.1+, and a picker for the four generated app icons. Tap a supplied live title to save it or search Apple Music, Spotify and Tidal. Station details include sharing; saved titles live in Settings. Alarms ring through iOS and offer Play station to open Dial; they do not promise unattended internet playback from a closed app. See [listening features and country setup](features-v25.md).

First launch uses a supported iPhone Region setting; an unsupported region starts on WNYC in New York metro. A saved station always wins on subsequent launches. Use my location, in the Stations location filter, opens a small sheet that requests approximate, foreground-only permission when needed; denied access or lookup errors stay in the sheet with Try Again and keep manual selection. It filters Stations to the detected country's main city (the default station's, else the dial with the most stations). No location coordinates are stored, and travel never changes the station automatically.

Simulator launches start muted. Device playback retains its normal volume. The interface has no advertisements; broadcasters may include advertising in their audio.

Native motion adds bookmark feedback, play/pause and layout-icon swaps, a short grid/list fade, and eased profile/timer disclosures. The tuner retains its established behavior, and system Reduce Motion removes the custom travel, blur, scale and particles. Search and filtering stay immediate. See the [motion record](motion.md).

## Catalogue and evidence

`Dial/stations.json` owns playable records. `Dial/station-profiles.json` owns profile data, optional images, source links, dated stream observations and explicit gaps. All 469 entries have profiles. 426 have a checked image source: 408 bundled station-artwork assets, the rest loading from their source URLs, which fall back to initials if unavailable. The 43 North America stations without a reviewed logo show initials. Missing language, bitrate or artwork stays explicitly missing rather than being invented. Genres and language classifications use directory fields and broadcaster website metadata, with limits recorded in profiles.

See the [expansion record](catalog-expansion.md), [stream checks](catalog/expansion/full-stream-checks.json), and [native playback checks](catalog/expansion/native-stream-checks.json). The [gap-fill record](gap-fill.md) covers ten further additions, all 22 missing thumbnails and the ESPN 1050 identity correction. The earlier 120 additions after the pilot passed both audio decoding and AVPlayer playback checks. The US batch has separate [evidence and verification](us-expansion.md), as does the [UK/BBC batch](uk-expansion.md). The [city dials record](city-dials.md) covers the October 18 move of 42 existing stations onto Paris, Madrid, Milan and Santiago FM dials. The original eleven and ten-station pilot retain their earlier verification evidence. Availability, geography restrictions, schedules and metadata can change independently of the app.

## Scope

Weather, rewind and automatic Shazam remain deliberately deferred. Favorites sync (iCloud key-value storage) and CarPlay were added on October 18, 2026; CarPlay works only in the Simulator until Apple grants the CarPlay audio entitlement. Accounts, subscriptions, station reports (removed after build 31) and music-service playlist writes were not added.
