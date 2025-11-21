import Foundation
import UIKit

/// Mock coffee API service for UI testing
/// Returns deterministic data without network calls
public actor MockCoffeeAPIService: CoffeeAPIServiceProtocol {
    public init() {}

    public func fetchRandomCoffee() async throws -> CoffeeAPIResponse {
        // No delay for UI tests - instant response
        return CoffeeAPIResponse(file: "https://mock.coffee.test/\(UUID().uuidString).jpg")
    }

    public func downloadImage(from url: URL) async throws -> Data {
        // No delay for UI tests - instant response

        // Create a deterministic test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)

        // Create a gradient or pattern so images look different
        let colors = [UIColor.systemBrown, UIColor.systemOrange, UIColor.systemYellow]
        let randomColor = colors.randomElement() ?? .brown
        randomColor.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))

        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return image.pngData()!
    }
}
