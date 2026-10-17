import SwiftUI

struct TuningDial: View {
    let stations: [Station]
    let selected: Station
    let onSelect: (Station) -> Void
    @Binding var previewFrequency: Double?
    let hapticsEnabled: Bool
    @State private var dragOrigin: Double?
    @State private var feedbackID = ""
    @MotionReduction private var reduceMotion

    private var pointsPerMHz: CGFloat { selected.band.pointsPerUnit }
    private var frequency: Double { previewFrequency ?? selected.tuningFrequency }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                FrequencyScale(frequency: frequency, stations: stations, band: selected.band)
                .animation(reduceMotion ? nil : DialMotion.tune, value: selected.id)
                .mask(LinearGradient(stops: [.init(color: .clear, location: 0), .init(color: .black, location: 0.12), .init(color: .black, location: 0.88), .init(color: .clear, location: 1)], startPoint: .leading, endPoint: .trailing))

                Rectangle()
                    .fill(Palette.accent)
                    .frame(width: 2, height: 90)
                    .offset(y: 26)
                Circle()
                    .fill(Palette.accent)
                    .frame(width: 6, height: 6)
                    .offset(y: -21)
            }
            .frame(width: geometry.size.width, height: 150)
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 2)
                .onChanged { value in
                    if dragOrigin == nil { dragOrigin = selected.tuningFrequency }
                    let proposed = (dragOrigin ?? selected.tuningFrequency) - value.translation.width / pointsPerMHz
                    previewFrequency = min(selected.band.range.upperBound, max(selected.band.range.lowerBound, proposed))
                    feedbackID = Station.nearest(to: frequency, in: stations)?.id ?? ""
                }
                .onEnded { _ in
                    let target = Station.nearest(to: frequency, in: stations)
                    withAnimation(reduceMotion ? nil : DialMotion.tune) {
                        if let target { onSelect(target) }
                        previewFrequency = nil
                        dragOrigin = nil
                    }
                })
        }
        .frame(height: 150)
        .sensoryFeedback(.selection, trigger: feedbackID) { _, _ in hapticsEnabled }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Tuning dial")
        .accessibilityValue("\(selected.frequencyText) \(selected.band.rawValue), \(selected.name)")
        .accessibilityHint("Swipe up or down to change station")
        .accessibilityAdjustableAction { direction in
            guard let index = stations.firstIndex(of: selected) else { return }
            let offset = direction == .increment ? 1 : -1
            onSelect(stations[(index + offset + stations.count) % stations.count])
        }
        .accessibilityIdentifier("tuning-dial")
    }
}

/// Canvas drawing is not implicitly animatable. Expose the frequency so the
/// scale moves through intermediate values instead of jumping to its target.
private struct FrequencyScale: View, Animatable {
    var frequency: Double
    let stations: [Station]
    let band: RadioBand
    var animatableData: Double {
        get { frequency }
        set { frequency = newValue }
    }

    var body: some View {
        Canvas { context, size in
            for tick in (band == .fm ? 750...1090 : 52...172) {
                let value = band == .fm ? Double(tick) / 10 : Double(tick) * 10
                let x = size.width / 2 + (value - frequency) * band.pointsPerUnit
                guard x > -20, x < size.width + 20 else { continue }
                let major = tick % 10 == 0
                let half = tick % 5 == 0
                var mark = Path()
                mark.move(to: CGPoint(x: x, y: 64))
                mark.addLine(to: CGPoint(x: x, y: major ? 100 : half ? 87 : 78))
                context.stroke(mark, with: .color(major ? Palette.ink.opacity(0.8) : Palette.secondary.opacity(0.55)), lineWidth: 1)
                if major {
                    context.draw(Text("\(band == .fm ? tick / 10 : tick * 10)").font(.system(size: 15, weight: .regular, design: .monospaced)).foregroundStyle(Palette.secondary), at: CGPoint(x: x, y: 37))
                }
            }
            for station in stations {
                let x = size.width / 2 + (station.tuningFrequency - frequency) * band.pointsPerUnit
                context.fill(Path(ellipseIn: CGRect(x: x - 2.5, y: 116, width: 5, height: 5)), with: .color(Palette.accent.opacity(0.8)))
            }
        }
    }
}

struct FrequencyReadout: View, Animatable {
    var frequency: Double
    let compact: Bool
    var band: RadioBand = .fm
    var animatableData: Double {
        get { frequency }
        set { frequency = newValue }
    }

    var body: some View {
        Text(String(format: band == .fm ? "%.1f" : "%.0f", frequency))
            .font(.system(size: compact ? 96 : 112, weight: .ultraLight, design: .rounded))
            .monospacedDigit()
            // Negative trailing tracking clipped the final glyph on-device.
            .padding(.trailing, 3)
            .minimumScaleFactor(0.65)
            .lineLimit(1)
            .accessibilityIdentifier("frequency")
    }
}
