import Foundation

public protocol CoffeeAPIServiceProtocol: Sendable {
    func fetchRandomCoffee() async throws -> CoffeeAPIResponse
    func downloadImage(from url: URL) async throws -> Data
}
