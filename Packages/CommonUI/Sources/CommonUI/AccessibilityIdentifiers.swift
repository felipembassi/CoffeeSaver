import Foundation

/// Centralized accessibility identifiers for UI testing.
///
/// Use these identifiers to locate UI elements in automated tests.
///
/// Example:
/// ```swift
/// // In view
/// Button("Save") { ... }
///     .accessibilityIdentifier(AccessibilityIdentifiers.Discovery.saveButton)
///
/// // In test
/// let saveButton = app.buttons[AccessibilityIdentifiers.Discovery.saveButton]
/// saveButton.tap()
/// ```
public enum AccessibilityIdentifiers {

    // MARK: - Coffee Discovery

    public enum Discovery {
        public static let coffeeImage = "discovery.coffeeImage"
        public static let saveButton = "discovery.saveButton"
        public static let skipButton = "discovery.skipButton"
        public static let loadingIndicator = "discovery.loadingIndicator"
        public static let errorView = "discovery.errorView"
        public static let retryButton = "discovery.retryButton"
    }

    // MARK: - Saved Coffees

    public enum SavedCoffees {
        public static let coffeeList = "saved.coffeeList"
        public static let coffeeCell = "saved.coffeeCell"
        public static let emptyState = "saved.emptyState"
        public static let deleteButton = "saved.deleteButton"
        public static let thumbnailImage = "saved.thumbnailImage"
    }

    // MARK: - Navigation

    public enum Navigation {
        public static let tabBar = "navigation.tabBar"
        public static let discoveryTab = "navigation.discoveryTab"
        public static let savedTab = "navigation.savedTab"
    }

    // MARK: - Common

    public enum Common {
        public static let loadingView = "common.loadingView"
        public static let errorView = "common.errorView"
        public static let retryButton = "common.retryButton"
    }
}
