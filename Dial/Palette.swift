import SwiftUI

enum Palette {
    private static func adaptive(_ light: UInt32, _ dark: UInt32) -> Color {
        func color(_ hex: UInt32) -> PlatformColor {
            PlatformColor(red: CGFloat((hex >> 16) & 255) / 255,
                          green: CGFloat((hex >> 8) & 255) / 255,
                          blue: CGFloat(hex & 255) / 255, alpha: 1)
        }
        #if os(iOS)
        return Color(uiColor: UIColor { traits in color(traits.userInterfaceStyle == .dark ? dark : light) })
        #else
        return Color(nsColor: NSColor(name: nil) { appearance in
            color(appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light)
        })
        #endif
    }
    static let paper = adaptive(0xF2F2F2, 0x000000)
    static let sheet = adaptive(0xF2F2F2, 0x121212)
    static let sheetSurface = adaptive(0xE5E5E5, 0x222222)
    static let ink = adaptive(0x242424, 0xF2F2F2)
    static let secondary = adaptive(0x666666, 0xA0A0A0)
    static let line = adaptive(0xCCCCCC, 0x333333)
    static let accent = adaptive(0x242424, 0xE5E5E5)
    static let surface = adaptive(0xE5E5E5, 0x161616)
    static let artwork = adaptive(0xFFFFFF, 0xFFFFFF)
    static let darkArtwork = adaptive(0x202020, 0x1A1A1A)
    static let artworkInk = adaptive(0x555555, 0x555555)
    static let onAccent = adaptive(0xFFFFFF, 0x000000)
}
