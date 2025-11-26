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
        // Given - use real CoffeeAPIClient with mock network
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
            modelContext: modelContext
        )

        // When
        await viewModel.loadRandomCoffee()

        // Then
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
        var mockNetwork = MockNetworkService()
        mockNetwork.errorToThrow = .networkError("Test error")
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
            modelContext: modelContext
        )

        // When
        await viewModel.loadRandomCoffee()

        // Then
        if case .error(let errorMessage) = viewModel.loadingState {
            #expect(!errorMessage.isEmpty)
        } else {
            Issue.record("Expected error state")
        }
    }

    @Test("Load coffee handles download error")
    func loadCoffeeHandlesDownloadError() async throws {
        // Given - use test-local mock for download error scenario
        let mockAPI = TestMockCoffeeAPIClient(shouldFailDownload: true)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: mockAPI,
            storageService: storageService,
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
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
            modelContext: modelContext
        )

        // Load a coffee first
        await viewModel.loadRandomCoffee()

        // When
        await viewModel.saveCoffee()

        // Then - Verify saved to SwiftData
        let descriptor = FetchDescriptor<CoffeeImage>()
        let savedCoffees = try modelContext.fetch(descriptor)
        #expect(savedCoffees.count == 1)
        #expect(savedCoffees.first?.remoteURL != nil)
    }

    @Test("Save coffee fails when no image loaded")
    func saveCoffeeFailsWhenNoImage() async throws {
        // Given
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
            modelContext: modelContext
        )

        // When - try to save without loading
        await viewModel.saveCoffee()

        // Then - should not save anything
        let descriptor = FetchDescriptor<CoffeeImage>()
        let savedCoffees = try modelContext.fetch(descriptor)
        #expect(savedCoffees.count == 0)
    }

    @Test("Save coffee handles storage error")
    func saveCoffeeHandlesStorageError() async throws {
        // Given - use test-local mock for storage error
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let mockStorage = TestMockImageStorageService(shouldFailSave: true)
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
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
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
            modelContext: modelContext
        )

        await viewModel.loadRandomCoffee()
        let initialURL = viewModel.currentCoffeeURL

        // When
        await viewModel.skipCoffee()

        // Then - URL should change (new coffee loaded)
        #expect(viewModel.currentCoffeeURL != initialURL)
    }

    // MARK: - Loading State Tests

    @Test("Initial state is idle")
    func initialStateIsIdle() throws {
        // Given
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        // When
        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
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
        let mockNetwork = MockNetworkService()
        let coffeeAPI = CoffeeAPIClient(networkService: mockNetwork)
        let storageService = ImageStorageService.forTesting()
        let modelContext = try createInMemoryModelContext()

        let viewModel = CoffeeDiscoveryViewModel(
            coffeeAPIClient: coffeeAPI,
            storageService: storageService,
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

// MARK: - Test-Only Mocks

/// Lightweight test mock for CoffeeAPIClient - only for specific error scenarios
private struct TestMockCoffeeAPIClient: CoffeeAPIClientProtocol {
    var shouldFailFetch = false
    var shouldFailDownload = false

    func fetchRandomCoffee() async throws -> CoffeeResponse {
        if shouldFailFetch {
            throw NetworkError.networkError("Test error")
        }
        return CoffeeResponse(file: "https://test.com/coffee.jpg")
    }

    func downloadImage(from url: URL) async throws -> Data {
        if shouldFailDownload {
            throw NetworkError.networkError("Test error")
        }
        return createTestImageData()
    }

    private func createTestImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        let image = renderer.image { ctx in
            UIColor.brown.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
        return image.jpegData(compressionQuality: 0.8) ?? Data()
    }
}

/// Lightweight test mock for ImageStorageService - only for specific error scenarios
private struct TestMockImageStorageService: ImageStorageServiceProtocol {
    var shouldFailSave = false
    var shouldFailLoad = false

    func saveImage(_ data: Data, withID id: UUID) async throws -> String {
        if shouldFailSave {
            throw StorageError.saveFailed(underlyingError: NSError(domain: "Test", code: -1))
        }
        return "/test/\(id).jpg"
    }

    func loadImage(from path: String) async throws -> UIImage {
        if shouldFailLoad {
            throw StorageError.fileNotFound(path: path)
        }
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10))
        return renderer.image { ctx in
            UIColor.brown.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }

    func deleteImage(at path: String) async throws {}

    func generateThumbnail(from data: Data, withID id: UUID) async throws -> String {
        "/test/\(id)_thumb.jpg"
    }
}
