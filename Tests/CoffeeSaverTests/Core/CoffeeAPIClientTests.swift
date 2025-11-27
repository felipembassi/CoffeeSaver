import Testing
import Foundation
@testable import Core
@testable import Features

@Suite("CoffeeAPIClient Tests")
struct CoffeeAPIClientTests {

    // MARK: - Unit Tests (Mocked Network)

    @Test("Fetch random coffee parses response correctly")
    func fetchRandomCoffeeSuccess() async throws {
        // Given
        let expectedURL = "https://coffee.alexflipnote.dev/random.jpg"
        let mockNetwork = MockNetworkService(
            nextResponseJSON: #"{"file": "\#(expectedURL)"}"#
        )
        let client = CoffeeAPIClient(networkService: mockNetwork)

        // When
        let response = try await client.fetchRandomCoffee()

        // Then
        #expect(response.file == expectedURL)
        #expect(response.file.hasPrefix("https://"))
    }

    @Test("Fetch random coffee handles malformed response")
    func fetchRandomCoffeeHandlesMalformedResponse() async throws {
        // Given
        let mockNetwork = MockNetworkService(
            nextResponseJSON: #"{"invalid": "response"}"#
        )
        let client = CoffeeAPIClient(networkService: mockNetwork)

        // When/Then
        await #expect(throws: Error.self) {
            _ = try await client.fetchRandomCoffee()
        }
    }

    @Test("Fetch random coffee handles network error")
    func fetchRandomCoffeeHandlesNetworkError() async throws {
        // Given
        let mockNetwork = MockNetworkService(
            errorToThrow: .networkError("Connection failed")
        )
        let client = CoffeeAPIClient(networkService: mockNetwork)

        // When/Then
        await #expect(throws: NetworkError.self) {
            _ = try await client.fetchRandomCoffee()
        }
    }

    @Test("Download image returns data")
    func downloadImageSuccess() async throws {
        // Given
        let testData = Data([0x89, 0x50, 0x4E, 0x47]) // PNG header bytes
        let mockNetwork = MockNetworkService(nextData: testData)
        let client = CoffeeAPIClient(networkService: mockNetwork)
        let url = URL(string: "https://example.com/coffee.jpg")!

        // When
        let imageData = try await client.downloadImage(from: url)

        // Then
        #expect(!imageData.isEmpty)
        #expect(imageData == testData)
    }

    @Test("Download image handles network error")
    func downloadImageHandlesNetworkError() async throws {
        // Given
        let mockNetwork = MockNetworkService(
            errorToThrow: .networkError("Download failed")
        )
        let client = CoffeeAPIClient(networkService: mockNetwork)
        let url = URL(string: "https://example.com/coffee.jpg")!

        // When/Then
        await #expect(throws: NetworkError.self) {
            _ = try await client.downloadImage(from: url)
        }
    }

    @Test("Invalid URL throws error")
    func invalidURLThrowsError() async {
        // Given - use mock to ensure we're testing client behavior, not network
        let mockNetwork = MockNetworkService(
            errorToThrow: .invalidURL
        )
        let client = CoffeeAPIClient(networkService: mockNetwork)

        // When/Then
        await #expect(throws: NetworkError.self) {
            _ = try await client.downloadImage(from: URL(string: "invalid")!)
        }
    }
}
