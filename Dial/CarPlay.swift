#if os(iOS)
import CarPlay
import Observation

/// CarPlay audio app: Favorites, the playing station's dial and every location, then the system
/// Now Playing screen. Playback, Now Playing info and next/previous come from the shared RadioPlayer.
@MainActor
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var interface: CPInterfaceController?
    private var radio: RadioPlayer { DialApp.sharedRadio }
    private let favorites = CPListTemplate(title: "Favorites", sections: [])
    private let dial = CPListTemplate(title: "Dial", sections: [])
    private let locations = CPListTemplate(title: "Locations", sections: [])

    func templateApplicationScene(_ scene: CPTemplateApplicationScene,
                                  didConnect interfaceController: CPInterfaceController) {
        interface = interfaceController
        favorites.tabImage = UIImage(systemName: "star.fill")
        favorites.emptyViewTitleVariants = ["No Favorites"]
        favorites.emptyViewSubtitleVariants = ["Save favorites from a station's details in Dial on iPhone."]
        dial.tabImage = UIImage(systemName: "radio")
        locations.tabImage = UIImage(systemName: "globe")
        locations.updateSections([CPListSection(items: countryItems())])
        CPNowPlayingTemplate.shared.isUpNextButtonEnabled = false
        CPNowPlayingTemplate.shared.isAlbumArtistButtonEnabled = false
        refresh()
        observe()
        let tabs = CPTabBarTemplate(templates: [favorites, dial, locations])
        interfaceController.setRootTemplate(tabs, animated: false, completion: nil)
    }

    func templateApplicationScene(_ scene: CPTemplateApplicationScene,
                                  didDisconnectInterfaceController interfaceController: CPInterfaceController) {
        interface = nil
    }

    private func observe() {
        withObservationTracking {
            _ = radio.library.selected
            _ = radio.library.favoriteIDs
            _ = radio.state
        } onChange: { [weak self] in
            Task { @MainActor in
                guard let self, self.interface != nil else { return }
                self.refresh()
                self.observe()
            }
        }
    }

    /// Favorites and the current dial follow the phone; the favorite button follows the playing station.
    private func refresh() {
        let library = radio.library
        favorites.updateSections([CPListSection(items: library.favorites.map(item))])
        let location = library.tuningLocations(in: library.region).first { $0.stations.contains(library.selected) }
        let stations = location?.stations ?? library.dialStations
        dial.updateSections([CPListSection(items: stations.map(item), header: location?.name ?? library.tuningLocationName,
                                           sectionIndexTitle: nil)])
        let isFavorite = library.favoriteIDs.contains(library.selected.id)
        let star = CPNowPlayingImageButton(image: UIImage(systemName: isFavorite ? "star.fill" : "star")!) { [weak self] _ in
            guard let self else { return }
            self.radio.library.toggleFavorite(self.radio.selected)
        }
        CPNowPlayingTemplate.shared.updateNowPlayingButtons([star])
    }

    private func item(for station: Station) -> CPListItem {
        let detail = station.hasDial ? "\(station.frequencyLabel) · \(station.tuningLocationName)"
            : "\(station.city) · \(station.region.country)"
        let item = CPListItem(text: station.name, detailText: detail, image: nil)
        item.setImage(ArtworkImages.image(for: station) { [weak item] image in item?.setImage(image) })
        item.isPlaying = station == radio.selected && radio.isActive
        item.playingIndicatorLocation = .trailing
        item.handler = { [weak self] _, completion in
            self?.play(station)
            completion()
        }
        return item
    }

    private func countryItems() -> [CPListItem] {
        RadioRegion.allCases.sorted { $0.country < $1.country }.map { region in
            let count = radio.library.stations(in: region).count
            let item = CPListItem(text: region.country, detailText: "\(count) \(count == 1 ? "station" : "stations")")
            item.accessoryType = .disclosureIndicator
            item.handler = { [weak self] _, completion in
                self?.showLocations(in: region)
                completion()
            }
            return item
        }
    }

    private func showLocations(in region: RadioRegion) {
        let items = radio.library.tuningLocations(in: region).map { location in
            let item = CPListItem(text: location.name, detailText: location.summary)
            item.accessoryType = .disclosureIndicator
            item.handler = { [weak self] _, completion in
                self?.show(location)
                completion()
            }
            return item
        }
        interface?.pushTemplate(CPListTemplate(title: region.country, sections: [CPListSection(items: items)]),
                                animated: true, completion: nil)
    }

    private func show(_ location: TuningLocation) {
        let template = CPListTemplate(title: location.name, sections: [CPListSection(items: location.stations.map(item))])
        interface?.pushTemplate(template, animated: true, completion: nil)
    }

    private func play(_ station: Station) {
        radio.select(station, autoplay: true)
        guard let interface, interface.topTemplate !== CPNowPlayingTemplate.shared else { return }
        interface.pushTemplate(CPNowPlayingTemplate.shared, animated: true, completion: nil)
    }
}
#endif
