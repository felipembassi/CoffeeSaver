import SwiftUI

// MARK: - Router

@MainActor
@Observable
public final class Router {
    public var path: NavigationPath
    public var sheet: AnyIdentifiable?
    public var fullScreenCover: AnyIdentifiable?
    public var overlay: AnyIdentifiable?

    private let rootScreen: AnyHashable
    private let preventsCyclicalNavigation: Bool
    private var screenStack: [AnyHashable] = []

    public init(
        rootScreen: any Hashable,
        path: NavigationPath = NavigationPath(),
        preventsCyclicalNavigation: Bool = true
    ) {
        self.rootScreen = AnyHashable(rootScreen)
        self.path = path
        self.sheet = nil
        self.fullScreenCover = nil
        self.overlay = nil
        self.preventsCyclicalNavigation = preventsCyclicalNavigation
    }

    // MARK: - Root Screen Inspection

    public var isRoot: Bool {
        return screenStack.isEmpty
    }

    public var root: any Hashable {
        return rootScreen
    }

    public var topScreen: any Hashable {
        return screenStack.last ?? rootScreen
    }

    // MARK: - Navigation Methods

    public func push(_ screen: any Hashable) {
        let hashableScreen = AnyHashable(screen)

        // If trying to push root screen when already at root, do nothing
        if hashableScreen == rootScreen && isRoot {
            return
        }

        // If cyclical navigation prevention is enabled and screen already exists in stack,
        // pop to it instead of pushing
        if preventsCyclicalNavigation && contains(screen) {
            popTo(screen)
        } else {
            path.append(screen)
            screenStack.append(hashableScreen)
        }
    }

    public func pop() {
        guard !screenStack.isEmpty else { return }
        path.removeLast()
        screenStack.removeLast()
    }

    public func popToRoot() {
        path.removeLast(screenStack.count)
        screenStack.removeAll()
    }

    public func presentSheet(_ screen: any Identifiable) {
        sheet = AnyIdentifiable(screen)
    }

    public func dismissSheet() {
        sheet = nil
    }

    public func presentFullScreenCover(_ screen: any Identifiable) {
        fullScreenCover = AnyIdentifiable(screen)
    }

    public func dismissFullScreenCover() {
        fullScreenCover = nil
    }

    public func showOverlay(_ screen: any Identifiable) {
        overlay = AnyIdentifiable(screen)
    }

    public func dismissOverlay() {
        overlay = nil
    }

    public func dismissAll() {
        sheet = nil
        fullScreenCover = nil
        overlay = nil
    }

    // MARK: - Stack Inspection

    private func contains<Screen: Hashable>(_ screen: Screen) -> Bool {
        let hashableScreen = AnyHashable(screen)
        // Check if screen is the root screen
        if hashableScreen == rootScreen {
            return true
        }
        // Check if screen is in the navigation path
        return screenStack.contains(hashableScreen)
    }

    private func popTo<Screen: Hashable>(_ screen: Screen) {
        let hashableScreen = AnyHashable(screen)

        // If popping to root screen, pop to root
        if hashableScreen == rootScreen {
            popToRoot()
            return
        }

        guard let index = screenStack.firstIndex(of: hashableScreen) else { return }

        // Calculate how many items to remove
        let itemsToPop = screenStack.count - index - 1

        // Remove from both path and screenStack
        if itemsToPop > 0 {
            path.removeLast(itemsToPop)
            screenStack = Array(screenStack.prefix(index + 1))
        }
    }
}
