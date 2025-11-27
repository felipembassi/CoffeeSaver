import XCTest

/// Accessibility identifiers matching AccessibilityIdentifiers.Discovery in CommonUI
private enum DiscoveryIDs {
    static let coffeeCard = "coffee-card"
    static let likeButton = "like-button"
    static let skipButton = "skip-button"
    static let loading = "discovery-loading"
    static let error = "discovery-error"
}

struct DiscoveryScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var coffeeCard: XCUIElement {
        // SwipeableCardView is a custom container view, not just an image
        // First try to find as otherElements, then fallback to any element with the identifier
        let card = app.otherElements[DiscoveryIDs.coffeeCard]
        if card.exists {
            return card
        }
        // Fallback: search across all element types
        return app.descendants(matching: .any).matching(identifier: DiscoveryIDs.coffeeCard).firstMatch
    }

    var likeButton: XCUIElement {
        app.buttons[DiscoveryIDs.likeButton]
    }

    var skipButton: XCUIElement {
        app.buttons[DiscoveryIDs.skipButton]
    }

    var loadingIndicator: XCUIElement {
        app.otherElements[DiscoveryIDs.loading]
    }

    var errorView: XCUIElement {
        app.otherElements[DiscoveryIDs.error]
    }

    // MARK: - Actions

    @discardableResult
    func waitForCardToLoad(timeout: TimeInterval = 30) -> Bool {
        // Wait for either card to load or error to appear
        // Use descendants query to find element with coffee-card identifier
        let cardQuery = app.descendants(matching: .any).matching(identifier: DiscoveryIDs.coffeeCard).firstMatch
        let cardExists = cardQuery.waitForExistence(timeout: timeout)
        if !cardExists && hasError {
            print("⚠️ Coffee card failed to load - error view is showing")
        }
        if !cardExists && isLoading {
            print("⚠️ Coffee card failed to load - still showing loading indicator")
        }
        return cardExists
    }

    func swipeCardRight() {
        coffeeCard.swipeRight()
    }

    func swipeCardLeft() {
        coffeeCard.swipeLeft()
    }

    func tapLikeButton() {
        likeButton.tap()
    }

    func tapSkipButton() {
        skipButton.tap()
    }

    // MARK: - Assertions

    var isCardVisible: Bool {
        coffeeCard.exists
    }

    var isLoading: Bool {
        loadingIndicator.exists
    }

    var hasError: Bool {
        errorView.exists
    }

    var currentImageURL: String? {
        guard coffeeCard.exists else { return nil }
        let label = coffeeCard.label
        // Extract URL from "coffee-image-{URL}" format
        if label.hasPrefix("coffee-image-") {
            return String(label.dropFirst("coffee-image-".count))
        }
        return nil
    }

    func waitForNewImage(previousURL: String?, timeout: TimeInterval = 5) -> Bool {
        // Use polling with proper QoS to avoid priority inversion
        let startTime = Date()
        let pollingInterval: TimeInterval = 0.1
        
        while Date().timeIntervalSince(startTime) < timeout {
            // Query on the main run loop to maintain proper QoS
            if let currentURL = currentImageURL, currentURL != previousURL {
                return true
            }
            
            // Use RunLoop.current.run to maintain User-interactive QoS
            RunLoop.current.run(until: Date(timeIntervalSinceNow: pollingInterval))
        }
        
        return false
    }
}
