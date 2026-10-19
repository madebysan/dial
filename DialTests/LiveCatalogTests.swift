import XCTest
@testable import Dial

final class LiveCatalogTests: XCTestCase {
    private static let gapFillIDs: Set<String> = ["us-radio-paradise", "us-groove-salad", "us-kroq", "us-kiis", "us-wins", "ar-nacional", "es-radio-clasica", "es-radio5", "fr-culture", "fr-nova"]
    private static let usExpansionIDs: Set<String> = ["us-kcrw", "us-kusc", "us-kqed", "us-kalw", "us-kexp", "us-kuow", "us-kopb", "us-kmhd", "us-wbez", "us-wfmt", "us-wbur", "us-wgbh", "us-wxpn", "us-whyy", "us-wamu", "us-weta", "us-kut", "us-kutx", "us-wwno", "us-wwoz", "us-know", "us-kcmp", "us-wlrn", "us-wlrn-classical"]
    private static let ukExpansionIDs: Set<String> = [
        "gb-bbc-radio-one",
        "gb-bbc-radio-one-anthems",
        "gb-bbc-radio-one-dance",
        "gb-bbc-1xtra",
        "gb-bbc-radio-three",
        "gb-bbc-radio-three-unwind",
        "gb-bbc-radio-four-extra",
        "gb-bbc-radio-five-live",
        "gb-bbc-asian-network",
        "gb-bbc-sounds-news",
        "gb-bbc-radio-scotland-fm",
        "gb-bbc-radio-scotland-mw",
        "gb-bbc-radio-orkney",
        "gb-bbc-radio-shetland",
        "gb-bbc-radio-nan-gaidheal",
        "gb-bbc-radio-ulster",
        "gb-bbc-radio-foyle",
        "gb-bbc-radio-wales-fm",
        "gb-bbc-radio-wales-am",
        "gb-bbc-radio-cymru",
        "gb-bbc-radio-cymru-2",
        "gb-bbc-radio-berkshire",
        "gb-bbc-radio-bristol",
        "gb-bbc-radio-cambridge",
        "gb-bbc-radio-cornwall",
        "gb-bbc-radio-coventry-warwickshire",
        "gb-bbc-radio-cumbria",
        "gb-bbc-radio-derby",
        "gb-bbc-radio-devon",
        "gb-bbc-radio-essex",
        "gb-bbc-radio-gloucestershire",
        "gb-bbc-radio-guernsey",
        "gb-bbc-radio-hereford-worcester",
        "gb-bbc-radio-humberside",
        "gb-bbc-radio-jersey",
        "gb-bbc-radio-kent",
        "gb-bbc-radio-lancashire",
        "gb-bbc-radio-leeds",
        "gb-bbc-radio-leicester",
        "gb-bbc-radio-lincolnshire",
        "gb-bbc-london",
        "gb-bbc-radio-manchester",
        "gb-bbc-radio-merseyside",
        "gb-bbc-radio-newcastle",
        "gb-bbc-radio-norfolk",
        "gb-bbc-radio-northampton",
        "gb-bbc-radio-nottingham",
        "gb-bbc-radio-oxford",
        "gb-bbc-radio-sheffield",
        "gb-bbc-radio-shropshire",
        "gb-bbc-radio-solent",
        "gb-bbc-radio-solent-west-dorset",
        "gb-bbc-radio-somerset-sound",
        "gb-bbc-radio-stoke",
        "gb-bbc-radio-suffolk",
        "gb-bbc-radio-surrey",
        "gb-bbc-radio-sussex",
        "gb-bbc-tees",
        "gb-bbc-three-counties-radio",
        "gb-bbc-radio-wiltshire",
        "gb-bbc-wm",
        "gb-bbc-radio-york",
        "gb-smooth-london",
        "gb-virgin",
        "gb-times",
        "gb-smooth-chill",
        "gb-capital-dance",
        "gb-heart-dance",
        "gb-nts1",
        "gb-nts2",
        "gb-rinse",
        "gb-resonance",
        "gb-funkids",
        "gb-capital-xtra",
    ]

    /// North America batch (Oct 18, 2026): US cities to ten stations each, new US cities and Canada, plus Reddit favorites.
    private static let naExpansionIDs: Set<String> = [
        "us-kfi", "us-knx", "us-krth", "us-kpcc", "us-kkjz", "us-klve", "us-kcbs", "us-kdfc",
        "us-koit", "us-kmel", "us-kits", "us-kllc", "us-krzz", "us-kcsm", "us-kiro-fm", "us-kiro-am",
        "us-kisw", "us-kndd", "us-kzok", "us-king", "us-knkx", "us-kkwf", "us-kink", "us-kxl",
        "us-kqac", "us-kxjm", "us-knrk", "us-kgon", "us-kwjj", "us-klth", "us-wbbm", "us-wxrt",
        "us-wgn", "us-wvaz", "us-wgci", "us-wusn", "us-wdrv", "us-wscr", "us-wojo", "us-wcxp",
        "us-wbz", "us-wzlx", "us-wcrb", "us-wxks", "us-weei", "us-wxrv", "us-wklb", "us-wers",
        "us-wmmr", "us-wip", "us-wdas", "us-wmgk", "us-kyw", "us-wxtu", "us-wusl", "us-wrti",
        "us-wtop", "us-whur", "us-wwdc", "us-wpgc", "us-wkys", "us-wmzq", "us-wjfk", "us-wlzl",
        "us-kbpa", "us-klbj-fm", "us-klbj-am", "us-kase", "us-kmfa", "us-krox", "us-khfi", "us-koop",
        "us-wyld", "us-wque", "us-wwl", "us-wrno", "us-wezb", "us-wnoe", "us-wkbu", "us-wtul",
        "us-kfxn", "us-kqql", "us-kdwb", "us-kstp", "us-keey", "us-ksjn", "us-wcco", "us-kfai",
        "us-wamr", "us-wmia", "us-whqt", "us-wcmq", "us-wxdj", "us-wedr", "us-whyi", "us-wkis",
        "us-wbgg", "us-wabe", "us-wsb", "us-wvee", "us-wamj", "us-wsrv", "us-wzgc", "us-wubl",
        "us-whta", "us-wclk", "us-wras", "us-kera", "us-kkxt", "us-wrr", "us-krld-am", "us-krld-fm",
        "us-khks", "us-kkda", "us-kmvk", "us-kzps", "us-kntu", "us-kuhf", "us-ktsu", "us-koda",
        "us-kglk", "us-ktbz", "us-kmjq", "us-kkbq", "us-ktrh", "us-kbxx", "us-kove", "us-kcfr",
        "us-kvod", "us-kuvo", "us-kbco", "us-ktcl", "us-kygo", "us-koa", "us-kqks", "us-krfx",
        "us-kvoq", "us-wdet", "us-wuom", "us-wrcj", "us-wwj", "us-wxyt", "us-wrif", "us-wjlb",
        "us-wmxd", "us-wycd", "us-wcsx", "us-wpln", "us-wnxp", "us-wmot", "us-wrlt", "us-wsm",
        "us-wsix", "us-wjxa", "us-wnrq", "us-wubt", "us-wcjk", "us-kpbs", "us-ksds", "us-kxsn",
        "us-kwfn", "us-kson", "us-xetra", "us-kioz", "us-kyxy", "us-klnv", "us-kogo", "ca-cbla",
        "ca-cbl", "ca-chfi", "ca-cftr", "ca-cfrb", "ca-ckis", "ca-cjrt", "ca-cilq", "ca-cfmz",
        "ca-cbf", "ca-cbfx", "ca-cbme", "ca-cjad", "ca-cibl", "ca-ckut", "ca-cbm", "ca-cjpx",
        "ca-ckvl", "ca-cbu-am", "ca-cbu-fm", "ca-cknw", "ca-cjax", "ca-ckpk", "ca-citr", "ca-cjjr",
        "ca-ckye", "ca-cbuf",
        // Added for their Reddit following (Oct 18, 2026).
        "us-knbr", "us-kfjc", "us-kpoo", "us-kpfa", "us-wrek", "us-wrfg", "us-wprb", "us-wkdu",
        "us-knon", "ca-ciut", "us-wmbr", "us-wxna", "us-kmoj", "us-kazi", "us-krbe", "us-wzbc",
    ]

    /// Run explicitly when changing stream URLs. Successful URL checks are cached
    /// for this device/date so repairing one feed does not replay the whole batch.
    @MainActor func testExpandedStreamsWithAVPlayer() async throws {
        let existing: Set<String> = ["wnyc", "wqxr", "wbgo", "wnyu", "wfuv", "wfmu", "futura", "diamante", "elpuente", "wabc", "clarin", "ar-la100", "ar-aspen", "ar-metro", "ar-mitre", "ar-rockandpop", "es-los40", "es-ser", "es-cadena100", "es-kissfm", "es-cadenadial"]
        let stations = Station.sample.filter { !existing.contains($0.id) && !Self.usExpansionIDs.contains($0.id) && !Self.ukExpansionIDs.contains($0.id) && !Self.gapFillIDs.contains($0.id) && !Self.naExpansionIDs.contains($0.id) }
        XCTAssertEqual(stations.count, 194)
        try await checkStreams(stations)
    }

    @MainActor func testUSStreamsWithAVPlayer() async throws {
        let stations = Station.sample.filter { Self.usExpansionIDs.contains($0.id) }
        XCTAssertEqual(stations.count, 24)
        try await checkStreams(stations)
    }

    @MainActor func testUKStreamsWithAVPlayer() async throws {
        let ids = Self.ukExpansionIDs.union(["gb-bbc-world", "gb-bbc2", "gb-bbc4", "gb-bbc6"])
        let stations = Station.sample.filter { ids.contains($0.id) }
        XCTAssertEqual(stations.count, 78)
        try await checkStreams(stations)
    }

    @MainActor func testNorthAmericaStreamsWithAVPlayer() async throws {
        let stations = Station.sample.filter { Self.naExpansionIDs.contains($0.id) }
        XCTAssertEqual(stations.count, 210)
        try await checkStreams(stations)
    }

    @MainActor func testGapFillStreamsWithAVPlayer() async throws {
        let stations = Station.sample.filter { Self.gapFillIDs.contains($0.id) }
        XCTAssertEqual(stations.count, 10)
        try await checkStreams(stations)
    }

    @MainActor private func checkStreams(_ stations: [Station]) async throws {
        let name = "DialLiveChecks.\(UUID())"
        let defaults = UserDefaults(suiteName: name)!
        defer { defaults.removePersistentDomain(forName: name) }
        let radio = RadioPlayer(library: Library(defaults: defaults), defaults: defaults)
        radio.volume = 0
        radio.tuningSoundEnabled = false
        let destination = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("catalog-live-checks.json")
        var records = (try? JSONDecoder().decode([Check].self, from: Data(contentsOf: destination))) ?? []
        var failures: [String] = []
        for station in stations {
            if records.contains(where: { $0.id == station.id && $0.url == station.streamURL.absoluteString && $0.played && Date().timeIntervalSince($0.checkedAt) < 3600 }) {
                print("CATALOG \(station.id): cached pass")
                continue
            }
            radio.select(station, autoplay: true)
            let deadline = Date().addingTimeInterval(24)
            while radio.state != .playing && Date() < deadline {
                try await Task.sleep(for: .milliseconds(150))
            }
            var played = radio.state == .playing
            if played {
                try await Task.sleep(for: .seconds(1))
                played = radio.state == .playing
            }
            let title = radio.liveTitle?.lowercased() ?? ""
            if title.range(of: "^(airtime|.*fm)\\s*-\\s*offline$", options: .regularExpression) != nil || title.contains("station is offline") {
                played = false
            }
            records.removeAll { $0.id == station.id }
            records.append(Check(id: station.id, url: station.streamURL.absoluteString, played: played,
                                 titleObserved: radio.liveTitle != nil, titleSample: radio.liveTitle, checkedAt: .now))
            try JSONEncoder().encode(records).write(to: destination, options: .atomic)
            print("CATALOG \(station.id): \(played ? "PASS" : "FAIL")")
            if !played { failures.append(station.id) }
            radio.pause()
        }
        XCTAssertTrue(failures.isEmpty, "Unplayable station IDs: \(failures.joined(separator: ", "))")
    }

    private struct Check: Codable {
        let id: String
        let url: String
        let played: Bool
        let titleObserved: Bool
        let titleSample: String?
        let checkedAt: Date
    }
}
