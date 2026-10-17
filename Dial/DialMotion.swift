import SwiftUI

enum DialMotion {
    static let tune = Animation.easeInOut(duration: 0.6)
    static let iconSwap = Animation.easeInOut(duration: 0.25)
    static let collection = Animation.easeOut(duration: 0.16)
    /// Mac secondary screens sliding over the player.
    static let screen = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.3)
    static let disclosure = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.22)
    static let favoriteFill = Animation.timingCurve(0.22, 1, 0.36, 1, duration: 0.15)
    static let favoriteSettle = Animation.timingCurve(0.34, 1.96, 0.64, 1, duration: 0.27)

    static let testReduceMotion: Bool = {
        #if DEBUG
        return ProcessInfo.processInfo.arguments.contains("--ui-testing")
            && ProcessInfo.processInfo.arguments.contains("--reduce-motion")
        #else
        return false
        #endif
    }()
}

/// Reads the system preference; the isolated UI-test override never changes device settings.
@propertyWrapper
struct MotionReduction: DynamicProperty {
    @Environment(\.accessibilityReduceMotion) private var systemValue
    var wrappedValue: Bool { systemValue || DialMotion.testReduceMotion }
}

/// Two stable glyphs share one slot, so reversals retarget without changing the hit area.
struct StateSymbol: View {
    let isOn: Bool
    let off: String
    let on: String
    var offOffset: CGFloat = 0
    @MotionReduction private var reduceMotion

    var body: some View {
        ZStack {
            Image(systemName: off)
                .offset(x: offOffset)
                .opacity(isOn ? 0 : 1)
                .scaleEffect(reduceMotion || !isOn ? 1 : 0.25)
                .blur(radius: reduceMotion || !isOn ? 0 : 2)
            Image(systemName: on)
                .opacity(isOn ? 1 : 0)
                .scaleEffect(reduceMotion || isOn ? 1 : 0.25)
                .blur(radius: reduceMotion || isOn ? 0 : 2)
        }
        .animation(reduceMotion ? nil : DialMotion.iconSwap, value: isOn)
        .accessibilityHidden(true)
    }
}

/// A bounded, activation-only celebration. Restored favorites never animate on appearance.
struct FavoriteSymbol: View {
    let isFavorite: Bool
    var size: CGFloat = 22
    @State private var activation = 0
    @MotionReduction private var reduceMotion

    var body: some View {
        ZStack {
            if !reduceMotion {
                Color.clear
                    .keyframeAnimator(initialValue: 1.0, trigger: activation) { _, progress in
                        ZStack {
                            ForEach(0..<8) { index in
                                let delay = Double(index) * 0.025
                                let phase = max(0, min(1, (progress - delay) / (1 - delay)))
                                let distance = 20 * (1 - pow(1 - phase, 3))
                                let angle = Double(index) * .pi / 4 - .pi / 2
                                Circle()
                                    .fill(Palette.accent)
                                    .frame(width: 2, height: 2)
                                    .offset(x: cos(angle) * distance, y: sin(angle) * distance)
                                    .opacity(isFavorite && progress >= delay ? 1 - phase : 0)
                            }
                        }
                    } keyframes: { _ in
                        MoveKeyframe(0)
                        LinearKeyframe(1, duration: 0.6)
                    }
                    .allowsHitTesting(false)
            }
            ZStack {
                Image(systemName: "star").opacity(isFavorite ? 0 : 1)
                Image(systemName: "star.fill").opacity(isFavorite ? 1 : 0)
            }
            .font(.system(size: size, weight: .regular))
            .foregroundStyle(Palette.accent)
            .animation(reduceMotion ? nil : DialMotion.favoriteFill, value: isFavorite)
            .phaseAnimator([1.0, 0.82, 1.0], trigger: activation) { content, scale in
                content.scaleEffect(reduceMotion || !isFavorite ? 1 : scale)
            } animation: { scale in
                scale == 0.82 ? .easeOut(duration: 0.08) : DialMotion.favoriteSettle
            }
        }
        .frame(width: 44, height: 44)
        .accessibilityHidden(true)
        .onChange(of: isFavorite) { _, selected in
            if selected && !reduceMotion { activation += 1 }
        }
    }
}
