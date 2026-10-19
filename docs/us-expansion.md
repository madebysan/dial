# US catalogue expansion

The first nationwide batch adds 24 feeds across twelve additional markets, bringing the US collection from 27 to 51 stations and the full catalogue from 141 to 165. The original New York-area IDs, favorites and saved band keys remain valid. This is a curated first batch focused on public news, music discovery, jazz and classical music; it is not a national popularity ranking or comprehensive US directory.

| Market | Added services |
|---|---|
| Los Angeles | KCRW, Classical KUSC |
| San Francisco | KQED, KALW |
| Seattle | KEXP, KUOW |
| Portland | OPB Radio, KMHD |
| Chicago | WBEZ, WFMT |
| Boston | WBUR, GBH 89.7 |
| Philadelphia | WXPN, WHYY |
| Washington, DC | WAMU, WETA Classical |
| Austin | KUT News, KUTX |
| New Orleans | WWNO, WWOZ |
| Minneapolis–Saint Paul | MPR News, The Current |
| Miami | WLRN News, WLRN Classical |

## Behavior and compatibility

The country selector now says United States. Its persisted `newYork` raw value stays unchanged for compatibility. New city collections have separate tuning scopes, so next/previous and the FM dial stay within the current market. The original New York, Newark, Jersey City, Bronx and South Orange entries retain a shared New York-area dial through an optional `tuningArea` catalogue field. Existing band-memory keys are preserved. World browsing, search and Favorites continue across countries.

The city field denotes the listening market for this batch; it need not be the transmitter’s licensed municipality. KCRW serves Los Angeles from Santa Monica, KMHD serves Portland from Gresham, and the Twin Cities services share one Minneapolis–Saint Paul market. WLRN Classical is a distinct HD2/online feed and has no invented FM frequency.

## Evidence and corrections

[Imported records](catalog/us-expansion/imported-records.json) retain the bounded Radio Browser records and reviewed broadcaster links. All 24 selected URLs passed [three-second audio decoding](catalog/us-expansion/stream-checks.json) and [native AVPlayer playback](catalog/us-expansion/native-stream-checks.json). Availability is a point-in-time observation from this connection, not a worldwide guarantee.

Broadcaster evidence corrected a KCRW directory variant from 88.9 to 89.9 FM and a GBH variant from 87.9 to 89.7 FM. A podcast episode presented as a KMHD stream was rejected. OPB’s original stream1 URL failed TLS; its stream5 endpoint decoded successfully. The WDNA candidate was not imported because a suitable current source/stream could not be verified in this pass. WLRN’s distinct classical service provides the second Miami feed.

Seventeen additions have inspected broadcaster artwork bundled locally. Seven use initials: KCRW, KQED, WFMT, GBH 89.7, WHYY, WAMU and The Current. Together with the thirteen existing gaps, twenty catalogue entries use initials. See the exact [artwork review](catalog/us-expansion/artwork-review.json). Classical KUSC uses Classical California branding; WWNO and WLRN use their broadcaster’s network branding. White logos have dark artwork backgrounds. KUTX uses its own logo, replacing the directory’s incorrectly reused KUT News image.

## Verification

The signed build and installation succeeded. All 26 targeted tests passed, including native playback of every new feed. US city search, local next/previous tuning, favorites, restored selections, the original New York-area group and its saved band keys were verified. Settings already includes System, Light and Dark appearance choices; the existing choices and dark-state persistence were verified against the updated player, station details and expanded catalogue. See the verification record.
