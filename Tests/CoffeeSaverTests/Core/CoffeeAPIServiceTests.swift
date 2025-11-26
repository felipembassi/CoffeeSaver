import Testing
import Foundation
@testable import Core
@testable import Features

@Suite("CoffeeAPIService Tests")
struct CoffeeAPIServiceTests {
    @Test("Fetch random coffee returns valid response")
    func fetchRandomCoffeeSuccess() async throws {
        let config = CoffeeAPIConfiguration.configuration(for: .production)
        let networkService = NetworkService(baseURL: config.baseURL)
        let client = CoffeeAPIClient(networkService: networkService)

        let response = try await client.fetchRandomCoffee()

        #expect(!response.file.isEmpty)
        #expect(response.file.hasPrefix("https://"))
    }

    @Test("Download image returns data")
    func downloadImageSuccess() async throws {
        let config = CoffeeAPIConfiguration.configuration(for: .production)
        let networkService = NetworkService(baseURL: config.baseURL)
        let client = CoffeeAPIClient(networkService: networkService)

        // First get a coffee URL
        let coffee = try await client.fetchRandomCoffee()
        guard let url = URL(string: coffee.file) else {
            Issue.record("Invalid URL from API")
            return
        }

        let imageData = try await client.downloadImage(from: url)

        #expect(!imageData.isEmpty)
    }

    @Test("Invalid URL throws error")
    func invalidURLThrowsError() async {
        let config = CoffeeAPIConfiguration.configuration(for: .production)
        let networkService = NetworkService(baseURL: config.baseURL)
        let client = CoffeeAPIClient(networkService: networkService)

        await #expect(throws: NetworkError.self) {
            _ = try await client.downloadImage(from: URL(string: "invalid")!)
        }
    }
}
