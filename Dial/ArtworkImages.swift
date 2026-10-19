import SwiftUI

/// Station artwork as images for the surfaces SwiftUI doesn't draw: Now Playing and CarPlay.
@MainActor
enum ArtworkImages {
    private static let cache = NSCache<NSString, PlatformImage>()
    private static var waiting: [String: [(PlatformImage?) -> Void]] = [:]

    /// Bundled artwork returns at once. Remote artwork returns `nil` and arrives later through `loaded`.
    static func image(for station: Station, loaded: @escaping (PlatformImage?) -> Void = { _ in }) -> PlatformImage? {
        let key = station.id as NSString
        if let cached = cache.object(forKey: key) { return cached }
        let profile = StationProfile.all[station.id]
        if let asset = profile?.artworkAsset, let image = PlatformImage(named: asset) {
            let tile = tile(image, dark: profile?.artworkBackground == "dark")
            cache.setObject(tile, forKey: key)
            return tile
        }
        guard let url = profile?.artworkURL else { return nil }
        if waiting[station.id] != nil {
            waiting[station.id]?.append(loaded)
            return nil
        }
        waiting[station.id] = [loaded]
        Task {
            let data = try? await URLSession.shared.data(from: url).0
            let image = data.flatMap(PlatformImage.init(data:)).map { tile($0, dark: profile?.artworkBackground == "dark") }
            if let image { cache.setObject(image, forKey: key) }
            waiting.removeValue(forKey: station.id)?.forEach { $0(image) }
        }
        return nil
    }

    /// Logos are drawn for Dial's light or dark tiles; keep that tile so dark logos stay visible on CarPlay.
    private static func tile(_ image: PlatformImage, dark: Bool) -> PlatformImage {
        #if os(iOS)
        let side: CGFloat = 400
        let format = UIGraphicsImageRendererFormat.default()
        format.opaque = true
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { context in
            UIColor(dark ? Palette.darkArtwork : Palette.artwork).setFill()
            context.fill(CGRect(x: 0, y: 0, width: side, height: side))
            let inset = side * 0.1
            let box = CGRect(x: inset, y: inset, width: side - inset * 2, height: side - inset * 2)
            let scale = min(box.width / max(image.size.width, 1), box.height / max(image.size.height, 1))
            let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
            image.draw(in: CGRect(x: box.midX - size.width / 2, y: box.midY - size.height / 2, width: size.width, height: size.height))
        }
        #else
        return image
        #endif
    }
}
