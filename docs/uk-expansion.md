# UK catalogue expansion

Build 0.12.0 (17) adds **74 feeds**, bringing the UK collection to **84 stations** and the full catalogue to **239**. Existing station records, IDs and stream URLs are unchanged. The four existing BBC profiles and artwork were refreshed without replacing their saved identities.

## BBC coverage

The BBC's [international listening directory](https://help.bbc.com/hc/en-us/articles/42652680528659-Update-on-access-to-BBC-Sounds-outside-the-UK) is the coverage checklist. All **66 listed feeds** are included:

| Directory section | Feeds | Coverage |
|---|---:|---|
| National and international services | 14 | Radio 1 and its Anthems/Dance services, 1Xtra, Radios 2–4 and their additional services, 5 Live, 6 Music, Asian Network, Live News and World Service English |
| UK nations and associated feeds | 11 | Scotland, Wales, Northern Ireland, Orkney and Shetland, including Welsh and Scottish Gaelic services and the extra feeds |
| Local services | 41 | The full local section of the BBC directory, including Guernsey, Jersey and Solent Dorset |

[Imported records](catalog/uk-expansion/imported-records.json) preserve every accepted ID, service ID, source record and selected URL. National and local BBC services are represented as online feeds; this pass does not assign terrestrial frequencies to them. Local and extra services can share their parent station's programming outside their own opt-outs. The Channel Islands feeds belong to the BBC/UK collection; their profile headers identify Guernsey and Jersey as Channel Islands rather than describing them as part of the UK. Both are Crown dependencies.

BBC URLs use its public worldwide/non-UK delivery paths. BBC Sounds access and programme rights vary by location. The catalogue does not promise access to every sporting event or on-demand programme.

## Additional UK services

The twelve additions beyond the BBC are Smooth London, Virgin Radio UK, Times Radio, Smooth Chill, Capital Dance, Heart Dance, Capital XTRA, NTS Radio 1, NTS Radio 2, Rinse FM, Resonance FM and Fun Kids. Existing Classic FM, Capital, Heart London, talkSPORT, LBC and Radio X remain in place.

Smooth London (102.2 FM) and Resonance FM (104.4 FM) join Heart London on the local London dial. Other additions remain online feeds. Natural name ordering makes stations at the same frequency, including online feeds, easier to browse. Existing country selection, bookmarks and band memory use the same saved keys.

## Source corrections and limits

Radio Browser supplied discovery metadata, checked against the BBC's own directory or broadcaster information where accessible. A generic BBC Radio 3 “Classic” listing was treated as a duplicate, not an additional station. Television streams and foreign-language World Service variants were not counted as extra UK radio stations.

The Wales Extra service uses `bbc_radio_wales_am`; the initially inferred `mw` identifier returned 404 and was corrected before import. Resonance's published cleartext URL failed the initial secure-port check; its HTTPS endpoint on the normal TLS port decoded successfully. No transport-security exception was added.

Two additional BBC services outside the international-directory checklist did **not** produce a verified playable international feed: **Radio 5 Sports Extra** and **Radio 6 Indie Forever**. The [failed checks](catalog/uk-expansion/unavailable-checks.json) are retained; neither is presented as playable. Sports Extra 2/3 event streams were not verified or imported. No UK-only endpoint, location-spoofing route or authenticated service was substituted.

Virgin Radio and Times Radio's websites returned browser-verification pages to the local fetch. Their directory metadata and publisher-hosted audio were reviewed separately. They currently use initials because an appropriate image was not verified in this pass. Account-specific directory URL flags were not used for other providers.

## Artwork

All 66 BBC feeds have original BBC artwork. Where a distinct opt-out logo was unavailable, the parent BBC network's logo is used and marked as network branding in the profile. Ten other additions have inspected broadcaster artwork. This adds 72 bundled images and refreshes four existing BBC images. The full catalogue now has **217 checked images, 22 initials fallbacks and 199 bundled assets**.

[Artwork review](catalog/uk-expansion/artwork-review.json) records sources and parent-brand usage. The supplied designs were retained. Whole-set contact sheets were inspected for identity and legibility; unrelated article images, sponsor logos and mismatched service logos were excluded.

## Verification

All 78 reviewed URLs (66 BBC plus twelve other additions) passed [audio decoding](catalog/uk-expansion/stream-checks.json). All 78 exact URLs also passed [native AVPlayer checks](catalog/uk-expansion/native-stream-checks.json). The targeted suite passed 24 tests with zero failures or skips and exit 0. It covered natural station ordering, legacy BBC favorites/selection, catalogue integrity, BBC national and Welsh playback, language metadata, Channel Islands display, London FM tuning, and US/worldwide regression checks. The player, search results and Welsh profile screenshots were inspected. A regression check reproduced the previous insertion-order behavior for online stations before the natural-name ordering change. The signed build and installation succeeded; build 17 is installed on san's iPhone. Simulator playback stayed muted and closed after testing.
