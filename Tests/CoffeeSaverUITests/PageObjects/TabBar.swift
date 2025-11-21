import XCTest

struct TabBar {
    let app: XCUIApplication

    // MARK: - Elements

    var discoverTab: XCUIElement {
        app.tabBars.buttons["Discover"]
    }

    var savedTab: XCUIElement {
        app.tabBars.buttons["Saved"]
    }

    // MARK: - Actions

    func navigateToDiscover() {
        discoverTab.tap()
    }

    func navigateToSaved() {
        savedTab.tap()
    }

    // MARK: - Assertions

    var isDiscoverSelected: Bool {
        discoverTab.isSelected
    }

    var isSavedSelected: Bool {
        savedTab.isSelected
    }
}
