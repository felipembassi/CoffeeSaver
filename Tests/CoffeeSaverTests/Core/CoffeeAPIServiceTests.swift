import Testing
import Foundation
@testable import Core

@Suite("CoffeeAPIService Tests")
struct CoffeeAPIServiceTests {
    @Test("Fetch random coffee returns valid response")
    func fetchRandomCoffeeSuccess() async throws {
        let service = CoffeeAPIService()

        let response = try await service.fetchRandomCoffee()

        #expect(!response.file.isEmpty)
        #expect(response.file.hasPrefix("https://"))
    }

    @Test("Download image returns data")
    func downloadImageSuccess() async throws {
        let service = CoffeeAPIService()

        // First get a coffee URL
        let coffee = try await service.fetchRandomCoffee()
        guard let url = URL(string: coffee.file) else {
            Issue.record("Invalid URL from API")
            return
        }

        let imageData = try await service.downloadImage(from: url)

        #expect(!imageData.isEmpty)
    }

    @Test("Invalid URL throws error")
    func invalidURLThrowsError() async {
        let service = CoffeeAPIService()

        await #expect(throws: NetworkError.self) {
            _ = try await service.downloadImage(from: URL(string: "invalid")!)
        }
    }
}
