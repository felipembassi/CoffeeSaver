import Foundation
internal import UIKit
@testable import Core

actor MockCoffeeAPIService: CoffeeAPIServiceProtocol {
    var shouldFailFetch = false
    var shouldFailDownload = false
    var fetchCallCount = 0
    var downloadCallCount = 0

    var mockCoffeeURL = "https://coffee.example.com/test.jpg"
    var mockImageData: Data = {
        // Create a minimal 1x1 red PNG image
        let size = CGSize(width: 1, height: 1)
        UIGraphicsBeginImageContext(size)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.pngData()!
    }()

    func fetchRandomCoffee() async throws -> CoffeeAPIResponse {
        fetchCallCount += 1

        if shouldFailFetch {
            throw NetworkError.networkError(NSError(domain: "test", code: -1))
        }

        return CoffeeAPIResponse(file: mockCoffeeURL)
    }

    func downloadImage(from url: URL) async throws -> Data {
        downloadCallCount += 1

        if shouldFailDownload {
            throw NetworkError.noData
        }

        return mockImageData
    }

    func reset() {
        shouldFailFetch = false
        shouldFailDownload = false
        fetchCallCount = 0
        downloadCallCount = 0
    }

    // Setters for test configuration
    func setShouldFailFetch(_ value: Bool) {
        shouldFailFetch = value
    }

    func setShouldFailDownload(_ value: Bool) {
        shouldFailDownload = value
    }
}
