# All Locations ranking

October 18, 2026. Stations › All Locations opens with the most-listened stations instead of dial order. A single city or Favorites keeps dial order, and search keeps the same popular-first order. The order lives in `Dial/all-locations-order.json`; stations not in it follow in catalogue order.

## Rules

1. **Top 30: at least half US,** alternating a US station with one from elsewhere, starting with WNYC. Each side is otherwise in audience order, with pinned picks: WNYC first, KEXP, KCRW and WFMU at the end of the US side, NTS Radio 1 and FIP at the end of the other side.
2. **31 to 100: by audience,** from each country's official survey: US weekly listeners (Nielsen, September 2026, via [RadioInsight](https://radioinsight.com/ratings/)), UK weekly reach (RAJAR, April–June 2026), and daily listeners for Spain (EGM 2nd wave 2026), France (Médiamétrie, April–June 2026) and Italy (Audiradio, April–June 2026). Weekly audiences are always larger than daily ones, so the European daily figures understate those stations a little.
3. **101 to 117: each remaining country's leading stations,** for countries without comparable audience totals (Canada, Argentina, Colombia, Brazil, Chile, Uruguay, Mexico, Japan), one round per country, then a second.
4. **Then the rest by audience,** then stations without a published figure.

Every figure and its source is in [audience figures](catalog/popularity/audience-figures.json). `AllLocationsOrderTests` checks that the IDs exist, that WNYC leads and that at least 15 of the top 30 are US stations.

## The first 117

| # | Station | Where | Basis |
|---|---|---|---|
| 1 | WNYC | New York | Pinned pick (552k weekly) |
| 2 | BBC Radio 2 | Uk | 12.4M weekly |
| 3 | Lite FM | New York | 3.7M weekly |
| 4 | BBC Radio 4 | Uk | 8.9M weekly |
| 5 | KTU | New York | 2.4M weekly |
| 6 | Capital | Uk | 8.8M weekly |
| 7 | Z100 | New York | 2.4M weekly |
| 8 | BBC Radio 1 | Uk | 7.5M weekly |
| 9 | K-Earth 101 | Los Angeles | 2.1M weekly |
| 10 | France Inter | Paris | 6.9M daily |
| 11 | Sunny 99.1 | Houston | 2.0M weekly |
| 12 | RTL 102.5 | Milan | 6.3M daily |
| 13 | Q104.3 | New York | 1.9M weekly |
| 14 | Radio Italia | Milan | 5.8M daily |
| 15 | KIIS FM | Los Angeles | 1.6M weekly |
| 16 | RDS | Milan | 5.6M daily |
| 17 | Mega 97.9 | New York | 1.6M weekly |
| 18 | BBC Radio 5 Live | Uk | 5.5M weekly |
| 19 | 1010 WINS | New York | 1.6M weekly |
| 20 | Radio Deejay | Milan | 5.1M daily |
| 21 | Power 105.1 | New York | 1.3M weekly |
| 22 | RTL | Paris | 4.9M daily |
| 23 | WBLS | New York | 1.3M weekly |
| 24 | Radio 105 | Milan | 4.8M daily |
| 25 | KEXP | Seattle | Pinned pick (141k weekly) |
| 26 | France Info | Paris | 4.7M daily |
| 27 | KCRW | Los Angeles | Pinned pick (503k weekly) |
| 28 | NTS Radio 1 | London | Pinned pick |
| 29 | WFMU | Jersey City | Pinned pick |
| 30 | FIP | Paris | Pinned pick (743k daily) |
| 31 | Cadena SER | Madrid | 4.4M daily |
| 32 | Classic FM | Uk | 4.3M weekly |
| 33 | LBC | Uk | 3.7M weekly |
| 34 | talkSPORT | Uk | 3.7M weekly |
| 35 | NRJ Paris | Paris | 3.7M daily |
| 36 | Nostalgie | Paris | 3.2M daily |
| 37 | Skyrock | Paris | 3.2M daily |
| 38 | Rai Radio 1 | Milan | 3.1M daily |
| 39 | Virgin Radio Italia | Milan | 3.1M daily |
| 40 | LOS40 | Madrid | 2.9M daily |
| 41 | RMC | Paris | 2.7M daily |
| 42 | Rai Radio 2 | Milan | 2.7M daily |
| 43 | BBC Radio 6 Music | Uk | 2.6M weekly |
| 44 | Europe 1 | Paris | 2.6M daily |
| 45 | Onda Cero | Madrid | 2.3M daily |
| 46 | Radio Monte Carlo Italia | Milan | 2.2M daily |
| 47 | France Culture | Paris | 2.2M daily |
| 48 | Radio Nova | Paris | 2.1M daily |
| 49 | Radio X | Uk | 1.9M weekly |
| 50 | BBC Radio 3 | Uk | 1.9M weekly |
| 51 | Cadena 100 | Madrid | 1.8M daily |
| 52 | Cadena Dial | Madrid | 1.5M daily |
| 53 | Rai Radio 3 | Milan | 1.2M daily |
| 54 | KISS FM | Madrid | 1.2M daily |
| 55 | KROQ | Los Angeles | 1.2M weekly |
| 56 | Hot 97 | New York | 1.2M weekly |
| 57 | 96.5 KOIT | San Francisco | 1.1M weekly |
| 58 | 97.1 The Drive | Chicago | 1.1M weekly |
| 59 | WFAN | New York | 1.0M weekly |
| 60 | RAC1 | Spain | 1.0M daily |
| 61 | France Musique | Paris | 1.0M daily |
| 62 | The Eagle 106.9 & 107.5 | Houston | 1.0M weekly |
| 63 | 93XRT | Chicago | 979k weekly |
| 64 | BBC World Service | Uk | 943k weekly |
| 65 | K-Love 107.5 | Los Angeles | 928k weekly |
| 66 | RNE Radio Nacional | Madrid | 895k daily |
| 67 | 93Q Country | Houston | 886k weekly |
| 68 | 106.1 Kiss FM | Dallas–Fort Worth | 857k weekly |
| 69 | 94.5 The Buzz | Houston | 797k weekly |
| 70 | BBC Radio 1Xtra | Uk | 769k weekly |
| 71 | 94WIP | Philadelphia | 766k weekly |
| 72 | Alice 97.3 | San Francisco | 758k weekly |
| 73 | 102.9 MGK | Philadelphia | 754k weekly |
| 74 | WBBM Newsradio | Chicago | 741k weekly |
| 75 | US99 | Chicago | 734k weekly |
| 76 | WTOP News | Washington, DC | 717k weekly |
| 77 | Catalunya Ràdio | Spain | 717k daily |
| 78 | Majic 102.1 | Houston | 713k weekly |
| 79 | V103 | Chicago | 699k weekly |
| 80 | KQED | San Francisco | 694k weekly |
| 81 | Kiss 108 | Boston | 689k weekly |
| 82 | Sunny 98.1 | San Diego | 686k weekly |
| 83 | Kool 108 | Minneapolis–Saint Paul | 673k weekly |
| 84 | Times Radio | Uk | 660k weekly |
| 85 | KCBS Radio | San Francisco | 654k weekly |
| 86 | 93.3 WMMR | Philadelphia | 646k weekly |
| 87 | 97.1 The Ticket | Detroit | 643k weekly |
| 88 | 104.3 The Score | Chicago | 636k weekly |
| 89 | V-103 | Atlanta | 629k weekly |
| 90 | Magic 93.9 | Miami | 629k weekly |
| 91 | Classical KUSC | Los Angeles | 596k weekly |
| 92 | 105.3 WDAS | Philadelphia | 580k weekly |
| 93 | KNX News | Los Angeles | 570k weekly |
| 94 | 107.7 The End | Seattle | 566k weekly |
| 95 | 101.3 KDWB | Minneapolis–Saint Paul | 560k weekly |
| 96 | WAMU | Washington, DC | 552k weekly |
| 97 | K104 | Dallas–Fort Worth | 551k weekly |
| 98 | BBC Asian Network | Uk | 548k weekly |
| 99 | 97.1 The River | Atlanta | 547k weekly |
| 100 | 94.7 WCSX | Detroit | 543k weekly |
| 101 | 98.1 CHFI | Toronto | Numeris summer 2026: #1 in Toronto |
| 102 | Radio Mitre | Buenos Aires | Kantar IBOPE Jul–Sep 2026: #1 AM in Buenos Aires (31%) |
| 103 | Olímpica Stereo Bogotá | Bogotá | ECAR 2025-2: #1 in Bogotá |
| 104 | Alpha FM | São Paulo | Kantar IBOPE Jan–Mar 2026: #1 in Greater São Paulo |
| 105 | Radio Bío-Bío | Santiago | Ipsos Mar–Jun 2025: leads men 25–59 in Santiago |
| 106 | Radio Monte Carlo | Uruguay | Buró de Radios/Factum 2025: #1 AM in Montevideo |
| 107 | La Ke Buena | Mexico City | UNAM 2025 (INRA data): among the top-rated stations in Mexico City |
| 108 | NHK World Radio Japan | Tokyo | Japan's public broadcaster; no comparable figures for Dial's other Japanese stations |
| 109 | CBC Radio One Vancouver | Vancouver | Numeris summer 2026: #1 in Vancouver |
| 110 | ICI Radio-Canada Première | Montreal | Numeris summer 2026: #1 in French-language Montreal |
| 111 | La 100 | Buenos Aires | Kantar IBOPE Jul–Sep 2026: #1 FM in Buenos Aires (21%) |
| 112 | Blu Radio | Colombia | ECAR 2025-2: #2 in Bogotá |
| 113 | Antena 1 | São Paulo | Kantar IBOPE early 2026: top 3 in São Paulo |
| 114 | Radio Cooperativa | Santiago | Activa Research 2024: most-listened in Santiago (self-reported) |
| 115 | Sarandí | Uruguay | Buró de Radios/Factum 2025: #2 AM in Montevideo |
| 116 | CJAD 800 | Montreal | Numeris spring 2026: #1 in English-language Montreal |
| 117 | CBC Radio One Toronto | Toronto | CBC Radio One, Canadians' top radio choice (CBC) |

## Limits

- Brand totals for Capital, BBC Radio 1 and Classic FM include their spin-offs; BBC World Service counts UK listeners only.
- The country leaders rest on market rankings, not comparable audience totals; Mexico City's rests on an older UNAM summary of INRA data.
- Audience surveys change each quarter; refresh the figures and regenerate the order when updating the catalogue.
