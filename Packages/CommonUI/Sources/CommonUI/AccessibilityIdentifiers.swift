import Foundation

/// Centralized accessibility identifiers for UI testing.
///
/// Use these identifiers to locate UI elements in automated tests.
///
/// Example:
/// ```swift
/// // In view
/// Button("Save") { ... }
///     .accessibilityIdentifier(AccessibilityIdentifiers.Discovery.likeButton)
///
/// // In test
/// let likeButton = app.buttons[AccessibilityIdentifiers.Discovery.likeButton]
/// likeButton.tap()
/// ```
public enum AccessibilityIdentifiers {

    // MARK: - Coffee Discovery

    public enum Discovery {
        public static let coffeeCard = "coffee-card"
        public static let likeButton = "like-button"
        public static let skipButton = "skip-button"
        public static let loading = "discovery-loading"
        public static let error = "discovery-error"
    }

    // MARK: - Saved Coffees

    public enum Saved {
        public static let grid = "saved-grid"
        public static let emptyState = "saved-empty-state"

        /// Returns the delete button identifier for a specific coffee ID
        public static func deleteButton(for coffeeID: UUID) -> String {
            "delete-button-\(coffeeID)"
        }

        /// Prefix used for delete buttons
        public static let deleteButtonPrefix = "delete-button-"
    }
}
