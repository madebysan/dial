import SwiftUI

struct StationInfo: View {
    let station: Station
    let radio: RadioPlayer
    private var library: Library { radio.library }
    @State private var showsDetails = false
    @MotionReduction private var reduceMotion
    @ScreenDismiss private var dismiss
    @Environment(\.inScreenStack) private var pushedFromStations
    private var profile: StationProfile? { StationProfile.all[station.id] }

    var body: some View {
        ScreenStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 26) {
                    HStack(spacing: 18) {
                        artwork
                        VStack(alignment: .leading, spacing: 6) {
                            Text(station.name)
                                .font(.system(.title, design: .rounded, weight: .semibold))
                                .accessibilityIdentifier("profile-name")
                            Text("\(station.frequencyLabel)")
                                .font(.system(.title3, design: .rounded, weight: .regular))
                            Text(profile?.locationLabel ?? "\(station.city), \(station.region.country)")
                                .font(.subheadline)
                                .foregroundStyle(Palette.secondary)
                        }
                    }

                    Button {
                        library.toggleFavorite(station)
                    } label: {
                        HStack(spacing: 10) {
                            FavoriteSymbol(isFavorite: library.favoriteIDs.contains(station.id))
                            Text(library.favoriteIDs.contains(station.id) ? "Remove favorite" : "Add favorite")
                                .font(.headline)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Palette.sheetSurface, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(library.favoriteIDs.contains(station.id) ? "Remove favorite" : "Add favorite")
                    .accessibilityIdentifier("favorite-toggle")
                    .sensoryFeedback(.success, trigger: library.favoriteIDs.contains(station.id)) { _, _ in radio.preferences.hapticsEnabled }

                    if let profile {
                        Text(profile.summary)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        VStack(alignment: .leading, spacing: 0) {
                            if let website = profile.website {
                                Link(destination: website) {
                                    Label("Station website", systemImage: "arrow.up.right")
                                        .frame(minHeight: 44, alignment: .leading)
                                }
                            }
                            ShareLink(item: StationSharing.text(for: station)) {
                                Label("Share", systemImage: "square.and.arrow.up")
                                    .frame(minHeight: 44, alignment: .leading)
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .buttonStyle(.borderless)
                        VStack(spacing: 13) {
                            detail(
                                "Format",
                                value: profile.genres.isEmpty
                                    ? "Not supplied" : profile.genres.joined(separator: ", "))
                            detail(
                                "Languages",
                                value: profile.languages.isEmpty
                                    ? "Not supplied" : profile.languages.joined(separator: ", "))
                        }
                        .padding(18)
                        .background(Palette.sheetSurface, in: RoundedRectangle(cornerRadius: 18))

                        DisclosureGroup(isExpanded: $showsDetails) {
                            VStack(alignment: .leading, spacing: 26) {
                                VStack(alignment: .leading, spacing: 15) {
                                    sectionTitle("Profile quality")
                                    evidence("Station & frequency", value: profile.identityStatus)
                                    evidence("Artwork", value: profile.artworkStatus)
                                    evidence(
                                        "Stream",
                                        value: "Audio decoded · \(profile.codec)"
                                            + (profile.bitrateKbps.map { ", \($0) kbps" } ?? " · bitrate not supplied"))
                                    evidence(
                                        "Song / program titles",
                                        value: profile.titlesObserved
                                            ? "Found in the sampled stream" : "Not seen in the short sample")
                                    Text("Checked \(profile.checkedOn). Stream availability and metadata can change.")
                                        .font(.caption)
                                        .foregroundStyle(Palette.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .accessibilityIdentifier("profile-quality")

                                if !profile.notes.isEmpty {
                                    VStack(alignment: .leading, spacing: 12) {
                                        sectionTitle("Still to check")
                                        ForEach(profile.notes, id: \.self) { note in
                                            HStack(alignment: .top, spacing: 10) {
                                                Image(systemName: "circle.dashed")
                                                    .font(.caption)
                                                    .foregroundStyle(Palette.secondary)
                                                    .padding(.top, 4)
                                                Text(note)
                                                    .font(.subheadline)
                                                    .fixedSize(horizontal: false, vertical: true)
                                            }
                                        }
                                    }
                                    .accessibilityIdentifier("profile-notes")
                                }

                                VStack(alignment: .leading, spacing: 6) {
                                    sectionTitle("Sources")
                                        .padding(.bottom, 5)
                                    ForEach(profile.sources) { source in
                                        Link(destination: source.url) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(source.label).font(.subheadline.weight(.medium))
                                                    Text(source.url.host() ?? source.url.absoluteString)
                                                        .font(.caption)
                                                        .foregroundStyle(Palette.secondary)
                                                }
                                                Spacer(minLength: 8)
                                                Image(systemName: "arrow.up.right")
                                                    .font(.caption.weight(.medium))
                                            }
                                            .frame(minHeight: 44)
                                            .padding(.vertical, 4)
                                        }
                                        .accessibilityHint("Opens source website")
                                    }
                                }
                            }
                            .padding(.top, 16)
                        } label: {
                            Text("Sources & stream details")
                                .font(.headline)
                        }
                        .animation(reduceMotion ? nil : DialMotion.disclosure, value: showsDetails)
                        .transaction { transaction in
                            if reduceMotion { transaction.disablesAnimations = true }
                        }
                    } else {
                        Text("This station’s profile has not been added yet.")
                            .foregroundStyle(Palette.secondary)
                    }
                }
                .padding(24)
            }
            .accessibilityIdentifier("station-info-scroll")
            .background(Palette.sheet)
            .foregroundStyle(Palette.ink)
            .navigationTitle("Station details")
            .inlineNavigationTitle()
            .toolbar {
                // On Mac, details opened from Stations use the system back button instead.
                if Platform.isPhone || !pushedFromStations {
                    ScreenCloseItem(identifier: "close-station-info") { dismiss() }
                }
            }
        }
        .tint(Palette.accent)
        .presentationBackground(Palette.sheet)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var artwork: some View {
        StationArtwork(station: station)
            .frame(width: 76, height: 76)
            .accessibilityHidden(true)
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.system(.headline, design: .rounded))
            .accessibilityAddTraits(.isHeader)
    }

    private func detail(_ title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 20) {
            Text(title).foregroundStyle(Palette.secondary)
            Spacer(minLength: 0)
            Text(value).multilineTextAlignment(.trailing)
        }
        .font(.subheadline)
        .accessibilityElement(children: .combine)
    }

    private func evidence(_ title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.subheadline.weight(.medium))
            Text(value).font(.subheadline).foregroundStyle(Palette.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }
}
