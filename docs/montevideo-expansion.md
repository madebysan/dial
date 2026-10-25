# Montevideo expansion

October 25, 2026. Adds ten stations to the Montevideo dial, which goes from five local frequencies to fifteen. Uruguay goes from 14 to 24 stations and the catalogue from 459 to 469. Existing station IDs, favorites and Uruguay's Other stations are unchanged.

## Rules

- **Popular first.** The picks start from the Buró de Radios del Uruguay's August–October 2025 survey of Montevideo and its metropolitan area (fieldwork by Factum), as reported by [El Observador](https://www.elobservador.com.uy/cultura-y-espectaculos/cuales-son-los-programas-radio-mas-escuchados-se-publico-el-nuevo-rating-del-dial-uruguayo-n6023282) and [Montevideo Portal](https://www.montevideo.com.uy/Pantallazo/-Que-radio-y-que-programas-son-los-mas-escuchados-por-la-audiencia-uruguaya--uc941986). The full tables are paywalled, so only the published leaders count as ratings evidence.
- **A mix of formats:** news and talk, sports, tropical, pop and rock, and the two public music and culture services not yet in Dial.
- **Two sources for every frequency:** Spanish Wikipedia (the station's article or ANDEBU's member list), plus the broadcaster's site, TuneIn's listing or the station's Radio Browser record.
- **Streams must play:** HTTPS only, a three-second decode, a check of the stream's name against the station, and playback in AVPlayer (`LiveCatalogTests.testMontevideoStreamsWithAVPlayer`).

## Result

| Station | Frequency | Format | Why |
|---|---|---|---|
| Inolvidable | 93.1 FM | Latin music | #1 FM, 2.6 weekly rating |
| Aire FM | 100.3 FM | Tropical, cumbia | #2 FM |
| Del Sol | 99.5 FM | Talk, news, music | *No toquen nada*, #2 programme |
| Azul FM | 101.9 FM | Music, talk | *Malos pensamientos*, #3 programme |
| Océano FM | 93.9 FM | Music | Uruguay's second FM station (1962) |
| FM Hit | 90.3 FM | Pop and rock hits | Pop and rock format |
| El Espectador | 810 AM | News, talk | News and talk format |
| 970 Universal | 970 AM | Sports, news | Sports format |
| Radio Clásica | 650 AM | Classical, opera | Public classical station |
| Radio Cultura | 1290 AM | Public radio | Public culture station |

Montecarlo and Sarandí, the top two AM stations, were already in Dial as Other stations.

## Notes and rejections

- **Inolvidable** is listed by ANDEBU under Canelones. It is measured in the Montevideo metropolitan survey, which covers the Canelones suburbs, and leads it, so it is on the Montevideo dial.
- **Radio Cultura** was called Emisora del Sur until July 2021, and its stream still carries the old name. One Radio Browser record lists it as 1280 AM; Wikipedia and TuneIn give 1290.
- **No usable stream:** Sport 890 (the #3 AM station) has a directory stream whose host doesn't resolve, and M24 (named among the top talk FM stations) returns a web page instead of audio. Neither broadcaster's site offered another stream. Concierto FM failed the same way.
- **Decoded but not picked:** Metrópolis 104.9 (licensed in Canelones, not in the ratings), La Treinta 1130 AM (another news and talk AM) and Radio Rural 610 AM (48 kbps, not in the ratings).
- **Artwork:** nine stations use a publisher or TuneIn logo. Radio Clásica uses a small directory image of the public broadcaster's mark, because no larger one was found. See [artwork review](catalog/montevideo-expansion/artwork-review.json).

## Sources and limits

[Imported records](catalog/montevideo-expansion/imported-records.json) list each station's frequency sources, popularity evidence, stream and artwork; the in-app profiles cite the same sources. See also [stream checks](catalog/montevideo-expansion/stream-checks.json) and [all candidates](catalog/montevideo-expansion/candidates.json).

Several broadcaster sites (Inolvidable, FM Hit, 970 Universal, Radio Clásica) didn't answer from outside Uruguay during the check; their streams did. Streams can move or go offline.
