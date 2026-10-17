# Tuning locations

Current behavior in **1.0 (33)**. San approved city/metro tuning after selecting MPR News exposed a two-station local dial behind a misleading United States label. Later screenshot corrections simplified the labels and helper copy. On October 17, 2026, San merged the separate Locations screen into the Stations filter, because both controls chose a location and the dial already follows the playing station.

## Player and selection

FM/AM tuning and previous/next follow the selected city/metro and band. The player has one bottom button: a centered capsule with the list icon and the city/metro name on one line, with trailing ellipsis for long names. Country and active-band station count remain in the accessibility description, not a visible subtitle. Tapping it opens Stations already filtered to that city/metro; All Locations in the filter widens it to the whole catalogue. Selecting a station anywhere immediately updates this scope; there is no separate location setting.

Stations without a listed local frequency use the country-wide **Other stations** group and artwork player. This label does not mean those broadcasters lack terrestrial frequencies. Their catalogue keys remain unchanged. The FM/AM/Other stations mode menu uses the same name.

There is no separate Locations screen. The Stations location filter groups stations exactly as the dial does: each country submenu lists only its city/metro dials and Other stations, with no country-wide entry because no dial covers a whole country. The list is built from `Library.tuningLocations(in:)`. New York, The Bronx, Newark, Jersey City and South Orange therefore appear once, as New York metro. A metro filter keeps each station's city label so its member cities stay visible.

## Country lookup and browsing

**Use my location** is the first item in the Stations location filter. It opens a small sheet that shows progress, then requests native approximate-location permission when needed; existing authorization continues to lookup. A lookup finds only the country, so a successful one closes the sheet and filters Stations to that country's main city: the default station's (New York metro, Montevideo), else the local dial with the most stations. It does not switch stations. Location Services off, denial, lookup failure, timeout or missing country coverage stays in the sheet with Try Again; the list remains available for manual choice.

The dial always has a location. First launch uses a supported iPhone Region setting; an unsupported region starts on WNYC in New York metro, with no country-choice screen. A valid saved station takes precedence over a changed device Region. No coordinates are stored and travel never changes the station automatically.

Stations opens at the dial's current city/metro; All Locations widens it to the worldwide catalogue, where list rows show country and city so repeated frequencies remain distinct. Favorites remains independent of the location filter.

## Identity and compatibility

- The US catalogue has eight FM frequencies reused across distinct tuning areas. The local dial avoids overlapping nationwide frequency positions; country-wide browsing keeps each station independently selectable.
- New York metro groups neighboring cities on one dial. Los Angeles uses one four-station FM dial after normalizing two earlier catalogue-batch scope keys.
- Station IDs, favorites, saved last station and catalogue payloads are preserved. Legacy city-based band preference keys remain readable.
- `Station.swift` defines scope identity and labels; `Library.swift` owns groups, selection and restoration; `StationLibrary.swift` owns the location filter, the Use my location sheet and the first-launch prompt.

## Verification

Verification owns current build/install evidence and limitations. Relevant retained evidence includes the original scope check, final scope/model run, onboarding/location flow, single-line player control, all twelve country flows, Other stations mode menu, and simplified location-row permission flow. Build-by-build changes remain in the [changelog](../CHANGELOG.md).
