import XCTest

struct DiscoveryScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var coffeeCard: XCUIElement {
        app.images["coffee-card"]
    }

    var likeButton: XCUIElement {
        app.buttons["like-button"]
    }

    var skipButton: XCUIElement {
        app.buttons["skip-button"]
    }

    var loadingIndicator: XCUIElement {
        app.otherElements["discovery-loading"]
    }

    var errorView: XCUIElement {
        app.otherElements["discovery-error"]
    }

    // MARK: - Actions

    @discardableResult
    func waitForCardToLoad(timeout: TimeInterval = 30) -> Bool {
        // Wait for either card to load or error to appear
        let cardExists = coffeeCard.waitForExistence(timeout: timeout)
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
        let predicate = NSPredicate { _, _ in
            guard let currentURL = self.currentImageURL else { return false }
            return currentURL != previousURL
        }

        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        return result == .completed
    }
}
