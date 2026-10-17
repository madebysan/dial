# Catalogue gaps · 0.13.0 (18)

Reviewed October 10, 2026. The catalogue contains 249 stations in twelve country collections. All have checked artwork; 231 profiles use bundled images and 18 retain previously checked remote images.

## Added stations

| Collection | Additions |
|---|---|
| United States | Radio Paradise Main Mix, SomaFM Groove Salad, KROQ, KIIS FM, 1010 WINS |
| Argentina | Radio Nacional AM 870 |
| Spain | RNE Radio Clásica, Radio 5 |
| France | France Culture, Radio Nova |

1010 WINS has one entry for its 92.3 FM / 1010 AM simulcast, placed on the New York FM dial. KROQ and KIIS share the established Los Angeles tuning area. National and internet services without a verified single local frequency remain Online.

The existing 239 station IDs, streams, frequencies and tuning areas are preserved. The only existing station-record change is the display name **ESPN Radio 1050**. Its WEPN 1050 stream remains unchanged. It is distinct from ESPN New York's 880 AM service, which is not added. The operator's indexed [station page](https://goodkarmabrands.com/espn-new-york/) lists separate lineups; direct retrieval returned 403. The 1050 logo independently identifies the retained frequency.

## Artwork repair

All 22 previously missing images are now bundled: Diamante, El Puente, WKCR, ESPN 1050, Radio Carve, Radio Uruguay, Éxito FM, 89 A Rádio Rock, Novabrasil, Radio Fórmula, NRJ, Nostalgie, AFN Tokyo, KCRW, KQED, WFMT, GBH, WHYY, WAMU, The Current, Virgin Radio UK and Times Radio. Each of the ten additions also has bundled artwork.

Publisher assets were used where available; Wikimedia and station-directory images fill remaining gaps. The [artwork review](catalog/gap-fill/artwork-review.json) records each source page, image URL, local asset name and SHA-256. All 32 images were decoded and visually inspected. SVG/WebP files were rasterized for consistent native rendering; the source URL remains in each profile. White Times Radio, Radio Fórmula and WINS marks use the app's existing dark artwork background.

Limits remain visible in the profiles:

- Diamante and El Puente use small directory images with matching names/frequencies; current publisher branding was not independently confirmed.
- Radio Uruguay uses its documented 2021 station mark; a newer station-specific mark was not verified.
- Radio Fórmula uses the parent brand without a conflicting frequency. The previously rejected 103.3 FM image is not used for the 104.1 FM entry.
- BBC programme rights and the prior BBC international-feed exclusions are unchanged.

## Remaining stream gaps

Del Sol, Océano FM and Urbana Play were researched but not imported. The first two selected hosts did not resolve from this connection, and older independently documented alternatives also failed. Urbana Play's directory HLS URL resolves to a missing child playlist. This does not establish that the broadcasters are offline or unavailable everywhere. [Failed checks](catalog/gap-fill/unavailable-checks.json).

Radio Nova initially failed DNS resolution, then passed a fresh check without routing, proxy or DNS changes. Every imported exact URL passed a three-second audio decode. [Imported records](catalog/gap-fill/imported-records.json), [decoder evidence](catalog/gap-fill/stream-checks.json). See verification for native playback, UI and installation status.

## A further 200 stations

The user's request authorized filling the identified gaps; the question about a further 200 is a feasibility discussion pending selection. No 200-station batch has been imported.

Radio Browser is a useful discovery catalogue with stable station UUIDs, country/language metadata and stream links, but its rows require review. This batch exposed duplicates, a wrong-city Urbana Play match, transient signed URLs and stale feeds. A larger batch can follow the existing resumable process: select a country/genre scope, exclude duplicates and regional copies, verify identity and artwork, retain stable stream entry URLs, decode each feed and test AVPlayer. Keep failed candidates separate from playable entries. No account, paid service or third-party model processing is needed for the established process.
