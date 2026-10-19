# North America expansion: US cities and Canada

October 18, 2026. Adds 210 stations across 22 cities: every existing US city outside New York goes from one or two stations to ten or more, seven US cities and three Canadian cities get their first dials, and Canada becomes Dial's 13th country. The catalogue goes from 249 to 459 stations. 194 came from ratings and press picks; 16 more were added the same evening because Reddit commenters in their cities name them often (see [Reddit validation](#reddit-validation)). Existing station IDs, favorites and New York are unchanged.

## Rules

- **At least 8 stations per city dial,** 10 in practice. Every city now has 9 to 14.
- **Popular first.** Each city starts from its most-listened stations in the latest public ratings: Nielsen Audio's September 2026 survey for the US (published by [RadioInsight](https://radioinsight.com/ratings/)) and the Numeris summer 2026 results for Canada (reported by Broadcast Dialogue, La Presse and Media in Canada).
- **A mix of formats** in each city: news or talk, public radio, classical or jazz, rock, hip-hop and R&B, country, pop, Spanish- or French-language stations where the audience is large, and one sports station.
- **One or two local favourites** that ratings miss, such as CHIRP in Chicago, WTUL in New Orleans or KSDS in San Diego, each with a press source, plus campus and community stations where they fill a gap.
- **Reddit favourites:** any station named by 14 or more distinct commenters in its city's radio threads that Dial didn't have was added if it passed the same frequency and stream checks, even past ten stations.
- **Left out:** national Christian networks, HD sub-channels, duplicate simulcasts and online-only stations.
- **Two sources for every frequency.** US frequencies come from the FCC licence record plus a second source: the station's name in the Nielsen listing or the iHeartRadio directory, its Radio Browser record, its website or Wikipedia. Canadian frequencies come from each station's Wikipedia article, because FCC's Canadian entries are wrong for several stations (CKNW on 980, which it left in February 2025; KiSS 92.5 on 97.5; Radio-Canada's two Montréal services swapped). The second source is the FCC entry where it agrees, Radio-Canada's or the station's own page, or a directory listing.
- **Streams must play in Dial:** HTTPS only, a three-second decode (`scripts/check-streams.py`), a check of the stream's directory name and metadata against the station, a check of where every redirect ends up (to catch geo-block messages), and playback in AVPlayer on the iPhone simulator (`LiveCatalogTests.testNorthAmericaStreamsWithAVPlayer`).

Each station's popularity evidence, two frequency sources, stream and artwork are in [imported records](catalog/na-expansion/imported-records.json); the profile in the app lists the same sources.

## Result

Stations added for their Reddit following are listed last in their row.

| City | Stations | Added (FM unless marked) |
|---|---|---|
| Los Angeles | 4 → 10 | KFI AM 640 640 AM, KNX News 1070 AM, K-Earth 101 101.1, LAist 89.3 89.3, KJazz 88.1 88.1, K-Love 107.5 107.5 |
| San Francisco | 2 → 14 | KCBS Radio 740 AM, Classical KDFC 90.3, 96.5 KOIT 96.5, 106 KMEL 106.1, Live 105 105.3, Alice 97.3 97.3, La Raza 93.3 93.3, KCSM Jazz 91 91.1, KNBR 680 680 AM, KFJC 89.7, KPOO 89.5, KPFA 94.1 |
| Seattle | 2 → 10 | KIRO Newsradio 97.3 97.3, Seattle Sports 710 710 AM, 99.9 KISW 99.9, 107.7 The End 107.7, 102.5 KZOK 102.5, Classical KING FM 98.1, KNKX 88.5 88.5, 100.7 The Wolf 100.7 |
| Portland | 2 → 10 | 101.9 KINK 101.9, FM News 101 KXL 101.1, All Classical 89.9, Jam'n 107.5 107.5, 94/7 Alternative 94.7, 92.3 KGON 92.3, 99.5 The Wolf 99.5, 106.7 The Eagle 106.7 |
| Chicago | 2 → 12 | WBBM Newsradio 780 AM, 93XRT 93.1, WGN Radio 720 720 AM, V103 102.7, WGCI 107.5 107.5, US99 99.5, 97.1 The Drive 97.1, 104.3 The Score 104.3, Que Buena 105.1 105.1, CHIRP Radio 107.1 |
| Boston | 2 → 12 | WBZ NewsRadio 1030 1030 AM, 100.7 WZLX 100.7, CRB Classical 99.5 99.5, Kiss 108 107.9, WEEI 93.7 93.7, 92.5 The River 92.5, Country 102.5 102.5, WERS 88.9 88.9, WMBR 88.1, WZBC 90.3 |
| Philadelphia | 2 → 12 | 93.3 WMMR 93.3, 94WIP 94.1, 105.3 WDAS 105.3, 102.9 MGK 102.9, KYW Newsradio 1060 AM, 92.5 XTU 92.5, Power 99 98.9, WRTI 90.1 90.1, WPRB 103.3, WKDU 91.7 |
| Washington, DC | 2 → 10 | WTOP News 103.5, 96.3 WHUR 96.3, DC101 101.1, WPGC 95.5 95.5, 93.9 WKYS 93.9, 98.7 WMZQ 98.7, 106.7 The Fan 106.7, El Zol 107.9 107.9 |
| Austin | 2 → 11 | 103.5 Bob FM 103.5, 93.7 KLBJ 93.7, NewsRadio KLBJ 590 AM, KASE 100.7 100.7, KMFA 89.5 89.5, 101X 101.5, 96.7 Kiss FM 96.7, KOOP 91.7 91.7, KAZI 88.7 |
| New Orleans | 2 → 10 | WYLD 98.5 98.5, Q93 93.3, WWL 870 870 AM, WRNO 99.5 99.5, B97 97.1, 101.1 WNOE 101.1, Bayou 95.7 95.7, WTUL 91.5 91.5 |
| Minneapolis–Saint Paul | 2 → 11 | 100.3 KFAN 100.3, Kool 108 107.9, 101.3 KDWB 101.3, KS95 94.5, K102 102.1, Classical MPR 99.5, WCCO 830 830 AM, KFAI 90.3 90.3, KMOJ 89.9 |
| Miami | 1 → 10 | Amor 107.5 107.5, Magic 93.9 93.9, Hot 105 105.1, Zeta 92.3 92.3, El Zol 106.7 106.7, 99 Jamz 99.1, Y100 100.7, Kiss Country 99.9 99.9, Big 105.9 105.9 |
| Atlanta | 0 → 12 | WABE 90.1 90.1, WSB 750 750 AM, V-103 103.3, Majic 107.5 107.5, 97.1 The River 97.1, 92.9 The Game 92.9, 94.9 The Bull 94.9, Hot 107.9 107.9, Jazz 91.9 WCLK 91.9, Album 88 88.5, WREK 91.1, WRFG 89.3 |
| Dallas–Fort Worth | 0 → 11 | KERA 90.1 90.1, KXT 91.7 91.7, Classical WRR 101.1 101.1, NewsRadio 1080 KRLD 1080 AM, 105.3 The Fan 105.3, 106.1 Kiss FM 106.1, K104 104.5, La Grande 107.5 107.5, Lone Star 92.5 92.5, Indie 88 88.1, KNON 89.3 |
| Houston | 0 → 11 | Houston Public Media News 88.7 88.7, KTSU 90.9 The Choice 90.9, Sunny 99.1 99.1, The Eagle 106.9 & 107.5 107.5, 94.5 The Buzz 94.5, Majic 102.1 102.1, 93Q Country 92.9, KTRH NewsRadio 740 740 AM, 97.9 The Box 97.9, Amor 106.5 106.5, 104.1 KRBE |
| Denver | 0 → 10 | CPR News 90.1, CPR Classical 88.1, KUVO Jazz 89.3 89.3, 97.3 KBCO 97.3, Channel 93.3 93.3, 98.5 KYGO 98.5, KOA Newsradio 850 AM, KS107.5 107.5, 103.5 The Fox 103.5, Indie 102.3 102.3 |
| Detroit | 0 → 10 | WDET 101.9 101.9, Michigan Public 91.7 91.7, WRCJ 90.9 90.9, WWJ Newsradio 950 950 AM, 97.1 The Ticket 97.1, 101 WRIF 101.1, 97.9 WJLB 97.9, Mix 92.3 92.3, 99.5 WYCD 99.5, 94.7 WCSX 94.7 |
| Nashville | 0 → 11 | WPLN News 90.3 90.3, Nashville Public Radio 91 One 91.1, WMOT Roots Radio 89.5, Lightning 100 100.1, WSM 650 650 AM, The Big 98 97.9, Mix 92.9 92.9, 105.9 The Rock 105.9, 101.1 The Beat 101.1, 96.3 Jack FM 96.3, WXNA 101.5 |
| San Diego | 0 → 10 | KPBS 89.5 89.5, Jazz 88.3 88.3, Sunny 98.1 98.1, 97.3 The Fan 97.3, KSON 103.7 103.7, 91X 91.1, Rock 105.3 105.3, KYXY 96.5 96.5, Que Buena 106.5 106.5, Newsradio 600 KOGO 600 AM |
| Toronto | 0 → 10 | CBC Radio One Toronto 99.1, CBC Music Toronto 94.1, 98.1 CHFI 98.1, 680 NewsRadio 680 AM, Newstalk 1010 1010 AM, KiSS 92.5 92.5, Jazz FM91 91.1, Q107 107.1, Classical 96.3 96.3, CIUT 89.5 |
| Montreal | 0 → 9 | ICI Radio-Canada Première 95.1, ICI Musique 100.7, CBC Radio One Montreal 88.5, CJAD 800 800 AM, CIBL 101.5 101.5, CKUT 90.3 90.3, CBC Music Montreal 93.5, QUB radio 99.5 99.5, CKVL 100.1 100.1 |
| Vancouver | 0 → 9 | CBC Radio One Vancouver 690 AM, CBC Music Vancouver 105.7, 730 CKNW 730 AM, JACK 96.9 96.9, 102.7 The Peak 102.7, CiTR 101.9 101.9, JR Country 93.7 93.7, RED FM 93.1 93.1, ICI Radio-Canada Première 97.7 |

## Corrections and rejections

- **Wrong streams caught by the identity check and replaced:** Seattle Sports 710 had KIRO-FM's feed; KDFC, KING FM and CRB Classical had playlist or alternate channels; WABE had its HD2 classical channel; Kiss Country 99.9 Miami pointed at WKSF in Asheville; 94.9 The Bull Atlanta pointed at WMSR.
- **Placeholder and geo-blocked streams rejected:** Indie88 Toronto and Virgin Radio 95.3 Vancouver play a "not available" loop. Cogeco's Montréal stations (98.5, CKOI, Rythme) redirect outside Canada to a recorded geo-block message, which the decoder accepted as audio; the redirect check caught it. They would play in Canada but can't be checked from here, so they're left out for now. QUB radio 99.5 and CKVL 100.1 took their places.
- **Blocked by App Transport Security:** the stream servers of KBOO Portland and CISM Montréal use ciphers without forward secrecy, so iOS and macOS refuse them (AVPlayer reports TLS error −9824). 106.7 The Eagle took KBOO's place.
- **No usable stream:** Bell Media's Canadian stations (CHUM, CHOM, Virgin Radio Montréal, Rouge) refuse outside requests, and Corus's The Edge and CFOX publish only plain HTTP. The next stations on each city's list took their places.
- **Frequency and licence fixes:** CKNW is on 730; KiSS West Coast (CKKS) was dropped because its licence is in Chilliwack, outside Vancouver. CBC Music Montréal (93.5) carries CBC's Eastern Music feed, the same stream as Toronto's.
- **Names updated to current branding:** 101.1 WNOE, KASE 100.7, K-Love 107.5, 680 NewsRadio, 104.3 The Score, 730 CKNW, The Eagle 106.9 & 107.5, WSB 750.

## Reddit validation

Checked against each city's subreddit through the Arctic Shift archive: 298 threads about local radio, 22,171 of the 25,873 comments Reddit lists for them (the archive misses some), and 21,106 after leaving out deleted comments and AutoModerator. A station counts as named when a distinct commenter mentions its call sign, brand or nickname. Thread links and per-station counts are in [Reddit validation](catalog/na-expansion/reddit-validation.json); no usernames or comment text are stored.

- **Agreement:** the most-named station in each city is already a ratings or press pick: KEXP (134 commenters) in Seattle, KROQ (83) and KCRW (75) in Los Angeles, KQED (89) in San Francisco, KUTX (98) and KOOP (69) in Austin, The Current (65) in the Twin Cities, KMHD (66) in Portland, WXPN (47) in Philadelphia, WERS (35) in Boston, 93XRT (35) in Chicago, WWOZ (21) in New Orleans, Lightning 100 (26) in Nashville.
- **Added (16):** stations Reddit names that Dial didn't have and that passed the frequency and stream checks: KNBR 680 (51), KFJC (27), KPOO (23) and KPFA (21) in San Francisco; WREK (46) and WRFG (23) in Atlanta; WPRB (30) and WKDU (23) in Philadelphia; KNON (28) in Dallas–Fort Worth; KAZI (18) in Austin; CIUT (17) in Toronto; WMBR (15) and WZBC (14) in Boston; WXNA (15) in Nashville; KMOJ (14) in the Twin Cities; 104.1 KRBE (14) in Houston. Each profile cites the thread with the most mentions.
- **Named often but not added:** KLOS (37), KXLU (36), KPFK (27) and KDAY (20) in Los Angeles, KPFT (37) in Houston, KBCS (30) in Seattle and WHIV in New Orleans have no stream Dial can play; KALX (32) in Berkeley didn't answer on its stream server; KBOO (25) in Portland fails App Transport Security; Rice's KTRU (22) no longer holds a Houston FM licence; KVRX (23) shares 91.7 with KOOP in Austin; WRVU (15) in Nashville is online only. Call signs that come up mostly in nostalgia threads for formats that no longer exist (KFRC, KFOG, KMET, WBCN, WFNX and others) weren't candidates.
- **Rarely named:** 46 of the 237 stations on these cities' dials get no mentions, mostly Spanish-language, country and mainstream pop stations such as US99, El Zol, KYGO and Y100. Nielsen shows large audiences for them, so they stay; Reddit leans toward public, college and community radio.

## Sources and limits

- **Reddit:** read through the Arctic Shift archive (https://arctic-shift.photon-reddit.com), because Reddit, web search and the in-app browser all refuse automated reads (and the PullPush archive declines agents).
- **TuneIn** was used only to find a broadcaster's own stream address, with TuneIn's partner parameters removed; such streams are noted in their profiles.
- **Artwork:** 167 stations have a reviewed logo bundled; 43 show initials (no logo found, or the logo failed review). See [artwork review](catalog/na-expansion/artwork-review.json).
- **Candidates:** [all 271 candidates](catalog/na-expansion/candidates.json) with the outcome for each, and [stream checks](catalog/na-expansion/stream-checks.json). Ratings shares for imported stations are in [Nielsen ratings](catalog/na-expansion/nielsen-ratings.json).
- Streams can move or go offline, and some broadcasters may block listeners outside their country.
