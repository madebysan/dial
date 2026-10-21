# Catalogue expansion

Later imports are recorded separately in [US catalogue expansion](us-expansion.md) and [UK catalogue expansion](uk-expansion.md). This page preserves the earlier 0.7.0 import and its evidence.

## Completed 0.7.0 scope

Build 0.7.0 (8) contains **141 stations**: 27 in the New York collection, 14 in Uruguay, and 10 each in Argentina, Spain, Brazil, Mexico, Colombia, Chile, the United Kingdom, France, Italy and Japan. The 21 existing station IDs were preserved, and 120 were added. These are curated starter collections rather than claimed audience rankings. Additional US markets are covered by the subsequent expansion linked above.

## Evidence and acceptance

Candidates came from bounded Radio Browser snapshots, reviewed broadcaster pages and source-provided stream URLs. Broken URLs, invalid TLS, insecure redirects, duplicate variants and unrelated country-themed feeds were rejected or replaced. No transport-security exception was added.

- [Imported directory/source records](catalog/expansion/imported-records.json)
- [Three-second decoding checks for the 120 additions](catalog/expansion/full-stream-checks.json)
- [AVPlayer checks for all 120 final IDs and exact URLs](catalog/expansion/native-stream-checks.json)
- [Earlier ten-station pilot checks](catalog/expansion/imported-pilot-checks.json)
- [Earlier pilot UI test summary](catalog/expansion/pilot-test-summary.json)

Every final addition decoded audio and reached stable playing state in AVPlayer on the dedicated iPhone simulator. The native validator saves each result and reuses recent successful checks for unchanged URLs, so a failed feed can be replaced without replaying the whole batch. This is point-in-time availability evidence, not a guarantee of continuous or worldwide access.

New York includes recognizable commercial stations, college/community programming, independent online music and New York Public Radio music services. Some initially considered feeds were unavailable or incompatible: the Chinese-language WKDM/WZRC endpoints failed TLS; WFDU's supplied endpoint failed certificate verification; WHCR redirected to cleartext HTTP; WNYC AM and New Standards links returned 404. Working alternatives were selected within the New York scope.

Uruguay includes national services and entries in Montevideo, Punta del Este, Carmelo and Paysandú. Several prominent candidates using unresolved nty.uy endpoints were replaced by working stations. Spain's COPE candidates decoded in FFmpeg but failed Apple's TLS requirements; Catalunya Ràdio was selected and passed the native check. Japan's ten entries use accessible Japanese public/local/independent services; unrelated Japan-themed aggregators were excluded.

## Metadata and artwork

All 141 stations have profile records with source links and available descriptive/technical metadata. Missing fields remain explicit. Station name, country, language and genre data are primarily directory-sourced; classifications may also use broadcaster descriptions and website language. Website reachability is not presented as independent proof of every directory field.

128 stations have checked images; 13 use the initials fallback. 110 artwork assets are bundled. Logos are original source images, with source URLs retained. Some represent broadcaster/network branding or small icons rather than high-resolution station posters. No replacement logos were invented. The bundled La 100 and LOS40 vectors preserve their original source content.

Local frequencies are retained only when supported by the record or broadcaster metadata and an identifiable local scope. Other feeds show Live stream. Locations can include a city or broader source-reported area. National online feeds are not assigned an arbitrary headquarters frequency.

## App behavior

Country browsing, location filtering, search, favorites and local tuning are integrated. Grid tiles have no star/info controls; list view keeps them. Original favorites and selected station IDs remain valid.

Simulator builds initialize playback volume to zero, including automated checks; this does not alter device volume.

Current truth belongs to the bundled catalogue and profiles. The native evidence covers the final accepted IDs/URLs.

## Final review corrections

Three Japanese feeds (Shonan Beach FM, FM Setagaya and Ottava) returned provider offline placeholders despite decoding audio. They were replaced with Moon Mission Radio, AFN Tokyo and Súper Tokio Radio. Every final replacement passed native playback; the catalogue still contains exactly ten Japan entries and 141 stations overall. Known offline-placeholder metadata is now a rejection condition in the reusable checker and native validation.

The [artwork review](catalog/expansion/artwork-review.json) records sponsor, TV and wrong-frequency image corrections. The final catalogue has 128 images and 13 initials fallbacks, with 110 bundled assets. Network-branded images are identified as such; no station logos were invented. GIF/WebP/ICO assets used for immediate thumbnails were converted to static PNG without changing their design. Final app data and signed-build payload were compared and match.
