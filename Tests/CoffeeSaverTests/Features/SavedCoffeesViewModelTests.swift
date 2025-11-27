import Testing
import Foundation
import SwiftData
internal import UIKit
@testable import Features
@testable import Core

@Suite("SavedCoffeesViewModel Tests")
@MainActor
struct SavedCoffeesViewModelTests {

    // MARK: - Load Image Tests

    @Test("Load image successfully")
    func loadImageSuccess() async throws {
        // Given
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = SavedCoffeesViewModel(
            dependencies: TestDependencies(storageService: mockStorage),
            modelContext: modelContext
        )

        // When
        let image = try await viewModel.loadImage(from: "/fake/path/test.jpg")

        // Then
        #expect(image.size.width > 0)
        #expect(image.size.height > 0)
        #expect(await mockStorage.loadCallCount == 1)
    }

    @Test("Load image handles error")
    func loadImageHandlesError() async throws {
        // Given
        let mockStorage = MockImageStorageService()
        await mockStorage.setShouldFailLoad(true)
        let modelContext = try createInMemoryModelContext()

        let viewModel = SavedCoffeesViewModel(
            dependencies: TestDependencies(storageService: mockStorage),
            modelContext: modelContext
        )

        // When/Then
        await #expect(throws: StorageError.self) {
            _ = try await viewModel.loadImage(from: "/fake/path/test.jpg")
        }
    }

    // MARK: - Delete Coffee Tests

    @Test("Delete coffee successfully")
    func deleteCoffeeSuccess() async throws {
        // Given
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = SavedCoffeesViewModel(
            dependencies: TestDependencies(storageService: mockStorage),
            modelContext: modelContext
        )

        // Create a test coffee image
        let coffeeID = UUID()
        let coffee = CoffeeImage(
            id: coffeeID,
            remoteURL: "https://coffee.example.com/test.jpg",
            localPath: "/fake/path/\(coffeeID).jpg",
            thumbnailPath: "/fake/path/\(coffeeID)_thumb.jpg"
        )
        modelContext.insert(coffee)
        try modelContext.save()

        // Verify it exists
        var descriptor = FetchDescriptor<CoffeeImage>()
        var coffees = try modelContext.fetch(descriptor)
        #expect(coffees.count == 1)

        // When
        try await viewModel.deleteCoffee(coffee)

        // Then
        #expect(await mockStorage.deleteCallCount == 2) // Main image + thumbnail

        // Verify removed from SwiftData
        descriptor = FetchDescriptor<CoffeeImage>()
        coffees = try modelContext.fetch(descriptor)
        #expect(coffees.count == 0)
    }

    @Test("Delete coffee without thumbnail succeeds")
    func deleteCoffeeWithoutThumbnail() async throws {
        // Given
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = SavedCoffeesViewModel(
            dependencies: TestDependencies(storageService: mockStorage),
            modelContext: modelContext
        )

        // Create coffee without thumbnail
        let coffeeID = UUID()
        let coffee = CoffeeImage(
            id: coffeeID,
            remoteURL: "https://coffee.example.com/test.jpg",
            localPath: "/fake/path/\(coffeeID).jpg",
            thumbnailPath: nil
        )
        modelContext.insert(coffee)
        try modelContext.save()

        // When
        try await viewModel.deleteCoffee(coffee)

        // Then
        #expect(await mockStorage.deleteCallCount == 1) // Only main image

        // Verify removed from SwiftData
        let descriptor = FetchDescriptor<CoffeeImage>()
        let coffees = try modelContext.fetch(descriptor)
        #expect(coffees.count == 0)
    }

    @Test("Delete coffee succeeds even with storage cleanup error")
    func deleteCoffeeSucceedsWithStorageError() async throws {
        // Given
        let mockStorage = MockImageStorageService()
        await mockStorage.setShouldFailDelete(true)
        let modelContext = try createInMemoryModelContext()

        let viewModel = SavedCoffeesViewModel(
            dependencies: TestDependencies(storageService: mockStorage),
            modelContext: modelContext
        )

        let coffeeID = UUID()
        let coffee = CoffeeImage(
            id: coffeeID,
            remoteURL: "https://coffee.example.com/test.jpg",
            localPath: "/fake/path/\(coffeeID).jpg",
            thumbnailPath: nil
        )
        modelContext.insert(coffee)
        try modelContext.save()

        // When - delete should succeed (SwiftData deletion is the source of truth)
        try await viewModel.deleteCoffee(coffee)

        // Then - coffee should be removed from SwiftData even if file cleanup failed
        // File cleanup errors are non-fatal to ensure data consistency
        let descriptor = FetchDescriptor<CoffeeImage>()
        let coffees = try modelContext.fetch(descriptor)
        #expect(coffees.count == 0)
    }

    @Test("Delete multiple coffees")
    func deleteMultipleCoffees() async throws {
        // Given
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = SavedCoffeesViewModel(
            dependencies: TestDependencies(storageService: mockStorage),
            modelContext: modelContext
        )

        // Create multiple coffees
        for i in 0..<3 {
            let coffeeID = UUID()
            let coffee = CoffeeImage(
                id: coffeeID,
                remoteURL: "https://coffee.example.com/test\(i).jpg",
                localPath: "/fake/path/\(coffeeID).jpg",
                thumbnailPath: "/fake/path/\(coffeeID)_thumb.jpg"
            )
            modelContext.insert(coffee)
        }
        try modelContext.save()

        var descriptor = FetchDescriptor<CoffeeImage>()
        let coffees = try modelContext.fetch(descriptor)
        #expect(coffees.count == 3)

        // When - delete first coffee
        try await viewModel.deleteCoffee(coffees[0])

        // Then
        descriptor = FetchDescriptor<CoffeeImage>()
        let remainingCoffees = try modelContext.fetch(descriptor)
        #expect(remainingCoffees.count == 2)
    }

    // MARK: - Helper Methods

    private func createInMemoryModelContext() throws -> ModelContext {
        let schema = Schema([CoffeeImage.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}

// MARK: - Test Dependencies

/// Mock dependencies for ViewModel tests
private struct TestDependencies: SavedCoffeesViewModel.Dependencies {
    let storageService: ImageStorageServiceProtocol
}
