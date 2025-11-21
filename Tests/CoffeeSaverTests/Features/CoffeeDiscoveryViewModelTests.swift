import Testing
import Foundation
import SwiftData
@testable import Features
@testable import Core
internal import UIKit

@Suite("CoffeeDiscoveryViewModel Tests")
@MainActor
struct CoffeeDiscoveryViewModelTests {

    // MARK: - Load Coffee Tests

    @Test("Load random coffee successfully")
    func loadRandomCoffeeSuccess() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // When
        await viewModel.loadRandomCoffee()

        // Then
        #expect(await mockAPI.fetchCallCount == 1)
        #expect(await mockAPI.downloadCallCount == 1)

        if case .loaded(let image) = viewModel.loadingState {
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        } else {
            Issue.record("Expected loaded state, got \(viewModel.loadingState)")
        }

        #expect(viewModel.currentCoffeeURL != nil)
    }

    @Test("Load coffee handles API error")
    func loadCoffeeHandlesAPIError() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        await mockAPI.setShouldFailFetch(true)
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // When
        await viewModel.loadRandomCoffee()

        // Then
        if case .error(let error) = viewModel.loadingState {
            #expect(error is NetworkError)
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test("Load coffee handles download error")
    func loadCoffeeHandlesDownloadError() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        await mockAPI.setShouldFailDownload(true)
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // When
        await viewModel.loadRandomCoffee()

        // Then
        if case .error = viewModel.loadingState {
            #expect(true) // Error state is correct
        } else {
            Issue.record("Expected error state")
        }
    }

    // MARK: - Save Coffee Tests

    @Test("Save coffee successfully")
    func saveCoffeeSuccess() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // Load a coffee first
        await viewModel.loadRandomCoffee()

        // When
        await viewModel.saveCoffee()

        // Then
        #expect(await mockStorage.saveCallCount == 1)
        #expect(await mockStorage.thumbnailCallCount == 1)

        // Verify saved to SwiftData
        let descriptor = FetchDescriptor<CoffeeImage>()
        let savedCoffees = try modelContext.fetch(descriptor)
        #expect(savedCoffees.count == 1)
        #expect(savedCoffees.first?.remoteURL != nil)
    }

    @Test("Save coffee fails when no image loaded")
    func saveCoffeeFailsWhenNoImage() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // When - try to save without loading
        await viewModel.saveCoffee()

        // Then - should not call storage
        #expect(await mockStorage.saveCallCount == 0)
    }

    @Test("Save coffee handles storage error")
    func saveCoffeeHandlesStorageError() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        await mockStorage.setShouldFailSave(true)
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // Load a coffee first
        await viewModel.loadRandomCoffee()

        // When
        await viewModel.saveCoffee()

        // Then - should be in error state
        if case .error = viewModel.loadingState {
            #expect(true)
        } else {
            Issue.record("Expected error state after save failure")
        }
    }

    // MARK: - Skip Coffee Tests

    @Test("Skip coffee loads next coffee")
    func skipCoffeeLoadsNext() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        await viewModel.loadRandomCoffee()
        let initialCallCount = await mockAPI.fetchCallCount

        // When
        await viewModel.skipCoffee()

        // Then
        #expect(await mockAPI.fetchCallCount == initialCallCount + 1)
    }

    // MARK: - Loading State Tests

    @Test("Initial state is idle")
    func initialStateIsIdle() throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        // When
        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // Then
        if case .idle = viewModel.loadingState {
            #expect(true)
        } else {
            Issue.record("Expected idle state")
        }
    }

    @Test("Loading state properties are correct")
    func loadingStatePropertiesCorrect() async throws {
        // Given
        let mockAPI = MockCoffeeAPIService()
        let mockStorage = MockImageStorageService()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            apiService: mockAPI,
            storageService: mockStorage,
            modelContext: modelContext
        )

        // When loaded
        await viewModel.loadRandomCoffee()

        // Then
        #expect(viewModel.currentImage != nil)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }

    // MARK: - Helper Methods

    private func createInMemoryModelContext() throws -> ModelContext {
        let schema = Schema([CoffeeImage.self])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
