import XCTest

final class CriticalPathTests: XCTestCase {
    var app: XCUIApplication!
    var discovery: DiscoveryScreen!
    var saved: SavedScreen!
    var tabBar: TabBar!

    override func setUpWithError() throws {
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["-UITesting"]
        app.launch()

        discovery = DiscoveryScreen(app: app)
        saved = SavedScreen(app: app)
        tabBar = TabBar(app: app)
    }

    override func tearDownWithError() throws {
        app = nil
        discovery = nil
        saved = nil
        tabBar = nil
    }

    // MARK: - Critical Path: Discovery → Save → View

    func testDiscoverySaveViewFlow() throws {
        // Given: Clear any existing saved coffees
        tabBar.navigateToSaved()
        saved.clearAll()

        // Given: Navigate back to Discovery tab
        tabBar.navigateToDiscover()
        XCTAssertTrue(tabBar.isDiscoverSelected, "Should be on Discovery tab")

        // When: Coffee image loads
        XCTAssertTrue(discovery.waitForCardToLoad(), "Coffee card should load")
        XCTAssertTrue(discovery.isCardVisible, "Coffee card should be visible")

        // Track current image URL
        let firstImageURL = discovery.currentImageURL
        XCTAssertNotNil(firstImageURL, "Should have image URL")

        // When: User likes the coffee (swipe right or tap button)
        discovery.tapLikeButton()

        // Then: New coffee should load with different URL
        XCTAssertTrue(discovery.waitForNewImage(previousURL: firstImageURL), "Next coffee should load with different URL")

        // When: Navigate to Saved tab
        tabBar.navigateToSaved()

        // Then: Saved coffee should appear in grid
        XCTAssertTrue(saved.waitForGrid(), "Saved grid should appear")
        XCTAssertFalse(saved.isEmpty, "Should not show empty state")
        XCTAssertGreaterThanOrEqual(saved.thumbnailCount, 1, "Should have at least 1 saved coffee")
    }

    // MARK: - Path 2: Discovery → Skip

    func testDiscoverySkipFlow() throws {
        // Given: Coffee is loaded
        XCTAssertTrue(discovery.waitForCardToLoad(), "Coffee card should load")
        let firstImageURL = discovery.currentImageURL
        XCTAssertNotNil(firstImageURL, "Should have image URL")

        // When: User skips the coffee
        discovery.tapSkipButton()

        // Then: New coffee should load with different URL
        XCTAssertTrue(discovery.waitForNewImage(previousURL: firstImageURL), "Next coffee should load with different URL")
    }

    // MARK: - Path 3: Swipe Gestures

    func testSwipeGestures() throws {
        // Given: Coffee is loaded
        XCTAssertTrue(discovery.waitForCardToLoad(), "Coffee card should load")
        let firstImageURL = discovery.currentImageURL
        XCTAssertNotNil(firstImageURL, "Should have image URL")

        // When: User swipes right (like)
        discovery.swipeCardRight()

        // Then: New coffee should load with different URL
        XCTAssertTrue(discovery.waitForNewImage(previousURL: firstImageURL), "Next coffee should load with different URL after like swipe")
        let secondImageURL = discovery.currentImageURL

        // When: User swipes left (skip)
        discovery.swipeCardLeft()

        // Then: New coffee should load with different URL
        XCTAssertTrue(discovery.waitForNewImage(previousURL: secondImageURL), "Next coffee should load with different URL after skip swipe")
    }

    // MARK: - Path 4: Empty State

    func testEmptyStateDisplay() throws {
        // Given: Navigate to Saved tab and clear all data
        tabBar.navigateToSaved()
        saved.clearAll()

        // Then: Empty state should be displayed
        XCTAssertTrue(saved.waitForEmptyState(timeout: 3), "Should show empty state")
        XCTAssertTrue(saved.isEmpty, "Should be empty")
        XCTAssertEqual(saved.thumbnailCount, 0, "Should have 0 saved coffees")
    }
}
