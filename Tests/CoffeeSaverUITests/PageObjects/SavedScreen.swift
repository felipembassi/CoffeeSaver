import XCTest

struct SavedScreen {
    let app: XCUIApplication

    // MARK: - Elements

    var emptyState: XCUIElement {
        app.otherElements["saved-empty-state"]
    }

    var grid: XCUIElement {
        app.scrollViews["saved-grid"]
    }

    func thumbnail(at index: Int) -> XCUIElement {
        grid.images.element(boundBy: index)
    }

    func deleteButton(for coffeeID: String) -> XCUIElement {
        app.buttons["delete-button-\(coffeeID)"]
    }

    var deleteAlert: XCUIElement {
        app.alerts.firstMatch
    }

    var deleteConfirmButton: XCUIElement {
        deleteAlert.buttons["Delete"]
    }

    var cancelButton: XCUIElement {
        deleteAlert.buttons["Cancel"]
    }

    // MARK: - Actions

    @discardableResult
    func waitForGrid(timeout: TimeInterval = 5) -> Bool {
        grid.waitForExistence(timeout: timeout)
    }

    @discardableResult
    func waitForEmptyState(timeout: TimeInterval = 5) -> Bool {
        emptyState.waitForExistence(timeout: timeout)
    }

    func tapDeleteButton(at index: Int) {
        let thumbnail = grid.images.element(boundBy: index)
        thumbnail.tap()
        // The delete button appears on top of the thumbnail
        thumbnail.buttons.firstMatch.tap()
    }

    func confirmDelete() {
        deleteConfirmButton.tap()
    }

    func cancelDelete() {
        cancelButton.tap()
    }

    func clearAll() {
        // Wait for the grid to load if it exists
        let gridExists = grid.waitForExistence(timeout: 3)

        // Delete all items one by one by tapping their delete buttons
        while gridExists && thumbnailCount > 0 {
            let currentCount = thumbnailCount

            // Find all delete buttons at app level matching the pattern
            let allButtons = app.buttons.allElementsBoundByIndex
            var foundButton: XCUIElement?

            for button in allButtons {
                if button.identifier.hasPrefix("delete-button-") {
                    foundButton = button
                    break
                }
            }

            if let deleteButton = foundButton, deleteButton.exists {
                // Wait for button to be hittable
                let buttonPredicate = NSPredicate { _, _ in
                    deleteButton.exists && deleteButton.isHittable
                }
                let buttonExpectation = XCTNSPredicateExpectation(predicate: buttonPredicate, object: nil)
                _ = XCTWaiter().wait(for: [buttonExpectation], timeout: 2)

                if deleteButton.isHittable {
                    deleteButton.tap()

                    // Wait for the delete confirmation alert
                    if deleteAlert.waitForExistence(timeout: 2) {
                        // Tap the confirm button
                        deleteConfirmButton.tap()

                        // Wait for the item count to decrease
                        let predicate = NSPredicate { _, _ in
                            self.thumbnailCount < currentCount || !self.grid.exists
                        }
                        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: nil)
                        _ = XCTWaiter().wait(for: [expectation], timeout: 3)
                    }
                } else {
                    // If delete button not hittable, break to avoid infinite loop
                    break
                }
            } else {
                // No more delete buttons found
                break
            }
        }

        // Wait for empty state to appear after all deletions
        _ = emptyState.waitForExistence(timeout: 3)
    }

    // MARK: - Assertions

    var isEmpty: Bool {
        emptyState.exists
    }

    var thumbnailCount: Int {
        grid.images.count
    }
}
