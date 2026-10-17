import AVFoundation

final class StreamMetadata: NSObject, AVPlayerItemMetadataOutputPushDelegate {
    let receive: @MainActor (String?) -> Void
    init(receive: @escaping @MainActor (String?) -> Void) { self.receive = receive }

    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        let items = groups.flatMap(\.items)
        Task { @MainActor in
            for item in items {
                let identifier = item.identifier?.rawValue.lowercased() ?? ""
                guard item.commonKey == .commonKeyTitle || identifier.contains("streamtitle") || identifier.contains("/tit2") else { continue }
                if let value = try? await item.load(.stringValue) {
                    receive(Self.clean(value))
                    return
                }
            }
        }
    }

    static func clean(_ value: String) -> String? {
        let cleaned = taggedTitle(value.replacingOccurrences(of: "\0", with: "")
            .split(whereSeparator: { $0.isNewline }).joined(separator: " "))
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : String(cleaned.prefix(500))
    }

    /// iHeartRadio-style titles append tags: `Artist - text="Song" song_spot="M" MediaBaseId="…"`.
    /// Keep the artist and the `text` value; leave ordinary titles unchanged.
    private static func taggedTitle(_ value: String) -> String {
        guard let text = value.firstMatch(of: /\btext="([^"]*)"/),
              let firstTag = value.firstMatch(of: /\s*\b[A-Za-z_]+="/) else { return value }
        let song = String(text.output.1).trimmingCharacters(in: .whitespaces)
        var artist = String(value[..<firstTag.range.lowerBound]).trimmingCharacters(in: .whitespaces)
        if artist.hasSuffix("-") { artist = String(artist.dropLast()).trimmingCharacters(in: .whitespaces) }
        switch (artist.isEmpty, song.isEmpty) {
        case (false, false): return "\(artist) - \(song)"
        case (true, false): return song
        case (false, true): return artist
        case (true, true): return ""
        }
    }
}
