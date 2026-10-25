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

/// Closes a secondary screen: dismisses the iPhone sheet, returns to the Mac player,
/// or, for a Mac page pushed inside another screen, goes back to that screen.
@propertyWrapper
struct ScreenDismiss: DynamicProperty {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.closeScreen) private var closeScreen
    @Environment(\.inScreenStack) private var pushed

    var wrappedValue: () -> Void {
        { if let closeScreen, !pushed { closeScreen() } else { dismiss() } }
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

enum ScreenTitleStyle { case inline, large, inherited }

extension View {
    /// A screen's title and way back.
    /// iPhone: the navigation bar, with Done when `close` is given and the accessory on the leading side.
    /// Mac: Dial's own header with a back arrow (Esc triggers it), since the menu bar panel draws the title bar
    /// but none of its buttons. With no `close`, the Mac arrow goes back one page.
    func screenHeader<Accessory: View>(
        _ title: String, style: ScreenTitleStyle = .inline, closeIdentifier: String = "close-screen",
        close: (() -> Void)?, @ViewBuilder accessory: () -> Accessory = { EmptyView() }
    ) -> some View {
        #if os(iOS)
        let accessory = accessory()
        return navigationTitle(title)
            .navigationBarTitleDisplayMode(style == .large ? .large : style == .inline ? .inline : .automatic)
            .toolbar {
                if Accessory.self != EmptyView.self {
                    ToolbarItem(placement: .topBarLeading) { accessory }
                }
                if let close {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: close).accessibilityIdentifier(closeIdentifier)
                    }
                }
            }
        #else
        return navigationTitle(title)
            .toolbar(.hidden, for: .windowToolbar)
            .navigationBarBackButtonHidden(true)
            .safeAreaInset(edge: .top, spacing: 0) {
                MacScreenHeader(title: title, identifier: closeIdentifier, close: close, accessory: accessory())
            }
        #endif
    }
}

#if os(macOS)
private struct MacScreenHeader<Accessory: View>: View {
    let title: String
    let identifier: String
    let close: (() -> Void)?
    let accessory: Accessory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 6) {
            Button {
                if let close { close() } else { dismiss() }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 30, height: 30)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .keyboardShortcut(.cancelAction)
            .help("Back")
            .accessibilityLabel("Back")
            .accessibilityIdentifier(identifier)
            Text(title)
                .font(.headline)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            accessory.buttonStyle(.plain)
        }
        .padding(.leading, 10)
        .padding(.trailing, 16)
        .frame(height: 48)
        .foregroundStyle(Palette.ink)
        .background(Palette.sheetSurface)
    }
}
#endif

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

extension View {
    #if os(macOS)
    /// Runs `action` when the window holding this view leaves the screen, such as the menu bar panel closing.
    func onWindowHidden(_ action: @escaping () -> Void) -> some View {
        background(WindowHiddenObserver(action: action))
    }
    #endif
}

#if os(macOS)
private struct WindowHiddenObserver: NSViewRepresentable {
    let action: () -> Void

    func makeNSView(context: Context) -> Watcher { Watcher(action: action) }
    func updateNSView(_ view: Watcher, context: Context) { view.action = action }

    final class Watcher: NSView {
        var action: () -> Void
        private var token: NSObjectProtocol?

        init(action: @escaping () -> Void) {
            self.action = action
            super.init(frame: .zero)
        }

        required init?(coder: NSCoder) { nil }

        deinit { if let token { NotificationCenter.default.removeObserver(token) } }

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let token { NotificationCenter.default.removeObserver(token) }
            token = nil
            guard let window else { return }
            token = NotificationCenter.default.addObserver(
                forName: NSWindow.didChangeOcclusionStateNotification, object: window, queue: .main
            ) { [weak self] _ in
                guard let self, let window = self.window, !window.occlusionState.contains(.visible) else { return }
                self.action()
            }
        }
    }
}
#endif
