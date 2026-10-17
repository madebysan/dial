import SwiftUI
#if os(iOS)
import UIKit
typealias PlatformColor = UIColor
typealias PlatformImage = UIImage
#else
import AppKit
typealias PlatformColor = NSColor
typealias PlatformImage = NSImage
#endif

/// iPhone and Mac share every screen; the few system differences live here.
enum Platform {
    /// Features that exist only on iPhone: alternate app icons, haptics and keep-awake while charging.
    static let isPhone: Bool = {
        #if os(iOS)
        true
        #else
        false
        #endif
    }()

    /// Instruction verbs and the system settings app, for copy that names them.
    static let tap = isPhone ? "Tap" : "Click"
    static let settingsApp = isPhone ? "iPhone Settings" : "System Settings"

    static func selectionHaptic(enabled: Bool) {
        #if os(iOS)
        if enabled { UISelectionFeedbackGenerator().selectionChanged() }
        #endif
    }

    static var isVoiceOverRunning: Bool {
        #if os(iOS)
        UIAccessibility.isVoiceOverRunning
        #else
        NSWorkspace.shared.isVoiceOverEnabled
        #endif
    }
}

extension Image {
    init(platformImage: PlatformImage) {
        #if os(iOS)
        self.init(uiImage: platformImage)
        #else
        self.init(nsImage: platformImage)
        #endif
    }
}

extension View {
    /// Compact navigation titles on iPhone; macOS windows and sheets have no navigation bar.
    func inlineNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }

    /// Menus draw only Dial's own label; macOS otherwise adds a bordered pop-up button and a second arrow.
    func plainMenuLabel() -> some View {
        #if os(iOS)
        self
        #else
        menuStyle(.button).buttonStyle(.plain).menuIndicator(.hidden)
        #endif
    }

    /// Mac plain lists run rows to the window edge; iPhone already insets them.
    func listRowEdgePadding() -> some View {
        #if os(iOS)
        self
        #else
        padding(.horizontal, 14)
        #endif
    }

    /// Buttons inside forms read as tappable text rows, as on iPhone, instead of Mac push buttons.
    func rowButtons() -> some View {
        #if os(iOS)
        self
        #else
        buttonStyle(.borderless)
        #endif
    }

    func largeNavigationTitle() -> some View {
        #if os(iOS)
        navigationBarTitleDisplayMode(.large)
        #else
        self
        #endif
    }
}

// MARK: - Secondary screens
// iPhone presents Stations, Locations, Settings and station details as sheets. On Mac they replace
// the player inside the same window, close with a back arrow, and push deeper pages in place.

struct CloseScreenAction {
    let action: () -> Void
    func callAsFunction() { action() }
}

extension EnvironmentValues {
    /// Set by the Mac player while a secondary screen covers it; nil on iPhone, where sheets dismiss.
    @Entry var closeScreen: CloseScreenAction? = nil
    /// True for Mac screens pushed inside another screen's navigation stack.
    @Entry var inScreenStack = false
}

/// Settings-style lists: inset-grouped on iPhone, a grouped form on Mac, where plain lists run edge to edge.
struct SettingsList<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        #if os(iOS)
        List { content }
        #else
        Form { content }.rowButtons()
        #endif
    }
}

/// Closes a secondary screen: dismisses the iPhone sheet, or returns to the Mac player.
@propertyWrapper
struct ScreenDismiss: DynamicProperty {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.closeScreen) private var closeScreen

    var wrappedValue: () -> Void {
        { if let closeScreen { closeScreen() } else { dismiss() } }
    }
}

/// A screen's navigation stack. A Mac screen opened from another screen pushes into that stack instead.
struct ScreenStack<Content: View>: View {
    @Environment(\.inScreenStack) private var inScreenStack
    @ViewBuilder var content: Content

    var body: some View {
        if Platform.isPhone || !inScreenStack {
            NavigationStack { content }.environment(\.inScreenStack, true)
        } else {
            content
        }
    }
}

/// Done on iPhone sheets; a back arrow to the player on Mac.
struct ScreenCloseItem: ToolbarContent {
    var identifier = "close-screen"
    let action: () -> Void

    var body: some ToolbarContent {
        #if os(iOS)
        ToolbarItem(placement: .confirmationAction) {
            Button("Done", action: action).accessibilityIdentifier(identifier)
        }
        #else
        ToolbarItem(placement: .navigation) {
            Button(action: action) { Label("Back", systemImage: "chevron.left") }
                .help("Back to player")
                .keyboardShortcut(.cancelAction)
                .accessibilityIdentifier(identifier)
        }
        #endif
    }
}

extension View {
    /// A deeper screen: a sheet on iPhone, a page pushed in the same window on Mac.
    /// On Mac, call it inside the presenting screen's `ScreenStack`.
    func screen<Item: Identifiable & Hashable, Detail: View>(
        item: Binding<Item?>, @ViewBuilder content: @escaping (Item) -> Detail
    ) -> some View {
        #if os(iOS)
        sheet(item: item, content: content)
        #else
        navigationDestination(item: item, destination: content)
        #endif
    }
}

extension ToolbarItemPlacement {
    /// Leading on iPhone; trailing on Mac so the back arrow stays first in the title bar.
    static var screenAccessory: ToolbarItemPlacement {
        #if os(iOS)
        .topBarLeading
        #else
        .primaryAction
        #endif
    }
}
