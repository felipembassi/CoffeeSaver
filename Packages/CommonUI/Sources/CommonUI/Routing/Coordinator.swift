import SwiftUI

// MARK: - ScreenType Protocol

/// A protocol that defines the requirements for screens in a coordinator-based navigation flow.
///
/// Screens must be both `Hashable` (for navigation path management) and `Identifiable`
/// (for SwiftUI list and sheet presentation).
///
/// ## Usage
/// Define your screens as an enum conforming to `ScreenType`:
///
/// ```swift
/// enum MyScreen: ScreenType {
///     case home
///     case detail(id: String)
///     case settings
///
///     var id: String {
///         switch self {
///         case .home: return "home"
///         case .detail(let id): return "detail-\(id)"
///         case .settings: return "settings"
///         }
///     }
/// }
/// ```
public protocol ScreenType: Hashable, Identifiable {}

// MARK: - Coordinator Protocol

/// A protocol that defines a coordinator for managing navigation flows in SwiftUI.
///
/// The Coordinator pattern separates navigation logic from view logic, making it easier to:
/// - Manage complex navigation flows
/// - Test navigation independently
/// - Reuse navigation patterns
/// - Handle deep linking
///
/// ## Overview
/// A coordinator manages a navigation flow by:
/// 1. Defining all possible screens in a `Screen` enum
/// 2. Using a `Router` to manage the navigation stack, sheets, and overlays
/// 3. Building views for each screen via `buildView(for:)`
/// 4. Notifying the parent when the flow completes via `onFinish`
///
/// ## Implementation Example
///
/// ```swift
/// struct MyFeatureCoordinator: View, Coordinator {
///     typealias Screen = MyFeatureScreen
///     typealias Result = Bool
///
///     @State var router: Router
///     let onFinish: ((Result) -> Void)?
///
///     init(onFinish: ((Result) -> Void)? = nil) {
///         self.router = Router(rootScreen: MyFeatureScreen.home)
///         self.onFinish = onFinish
///     }
///
///     var body: some View {
///         buildView(for: .home)
///             .coordinatorView(
///                 isNested: false,
///                 router: router,
///                 screenType: Screen.self
///             ) { screen in
///                 buildView(for: screen)
///             }
///     }
///
///     @MainActor
///     @ViewBuilder
///     func buildView(for screen: Screen) -> some View {
///         switch screen {
///         case .home:
///             HomeView(viewModel: HomeViewModel())
///         case .detail(let id):
///             DetailView(id: id, viewModel: DetailViewModel())
///         }
///     }
/// }
/// ```
///
/// ## Navigation Methods
///
/// The `Router` provides these navigation methods:
/// - `router.push(screen)` - Push onto navigation stack
/// - `router.pop()` - Pop current screen
/// - `router.popToRoot()` - Pop to root screen
/// - `router.presentSheet(screen)` - Present as sheet
/// - `router.presentFullScreenCover(screen)` - Present as full screen cover
/// - `router.dismissSheet()` - Dismiss sheet
/// - `router.dismissFullScreenCover()` - Dismiss full screen cover
///
/// ## Best Practices
///
/// 1. **Centralize Navigation Logic** - Keep all navigation decisions in the coordinator
/// 2. **Use Meaningful Screen IDs** - Ensure screen IDs are unique and descriptive
/// 3. **Handle Router State Changes** - React to navigation state when needed
/// 4. **Keep Views Focused** - Views should focus on presentation, coordinators handle navigation flow
///
/// ## See Also
/// - ``Router`` - The navigation state manager
/// - ``ScreenType`` - Protocol for screen definitions
public protocol Coordinator: View {
    /// The screen type defining all possible screens in this coordinator's flow.
    ///
    /// Typically an enum conforming to ``ScreenType``.
    associatedtype Screen: ScreenType

    /// The result type returned when this coordinator's flow completes.
    ///
    /// Use `Void` if the coordinator doesn't need to return a result.
    /// Use a specific type (e.g., `Bool`, `String`, custom type) to pass data back to the parent.
    associatedtype Result

    /// The view type returned by ``buildView(for:)``.
    ///
    /// Usually inferred automatically by the compiler.
    associatedtype ContentView: View

    /// The router managing navigation state for this coordinator.
    ///
    /// The router handles:
    /// - Navigation stack (push/pop)
    /// - Sheet presentation
    /// - Full screen covers
    /// - Overlays
    ///
    /// Initialize the router with a root screen:
    /// ```swift
    /// @State var router: Router
    ///
    /// init() {
    ///     self.router = Router(rootScreen: MyScreen.home)
    /// }
    /// ```
    var router: Router { get }

    /// Callback invoked when the coordinator's flow completes.
    ///
    /// Call this with a result value when the user completes or cancels the flow.
    ///
    /// ## Example
    /// ```swift
    /// func handleDone() {
    ///     onFinish?(true) // Flow completed successfully
    /// }
    ///
    /// func handleCancel() {
    ///     onFinish?(false) // Flow was cancelled
    /// }
    /// ```
    var onFinish: ((Result) -> Void)? { get }

    /// Builds the view for a given screen.
    ///
    /// This method is called by the coordinator to create the appropriate view for each screen
    /// in the navigation flow.
    ///
    /// - Parameter screen: The screen to build a view for
    /// - Returns: The view representing the given screen
    ///
    /// ## Example
    /// ```swift
    /// @MainActor
    /// @ViewBuilder
    /// func buildView(for screen: Screen) -> some View {
    ///     switch screen {
    ///     case .list:
    ///         ListView(viewModel: ListViewModel())
    ///     case .detail(let item):
    ///         DetailView(item: item, viewModel: DetailViewModel())
    ///     case .settings:
    ///         SettingsView()
    ///     }
    /// }
    /// ```
    @MainActor
    @ViewBuilder
    func buildView(for screen: Screen) -> ContentView
}
