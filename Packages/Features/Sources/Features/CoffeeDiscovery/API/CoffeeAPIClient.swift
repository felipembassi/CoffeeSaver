import Foundation
import Core

// MARK: - Protocol

/// Protocol defining the Coffee API client interface.
///
/// Use this protocol to declare dependencies on the Coffee API without
/// coupling to the concrete implementation. This enables easy testing
/// by injecting mock implementations.
///
/// Example:
/// ```swift
/// class CoffeeViewModel {
///     private let coffeeAPI: CoffeeAPIClientProtocol
///
///     init(coffeeAPI: CoffeeAPIClientProtocol) {
///         self.coffeeAPI = coffeeAPI
///     }
///
///     func loadCoffee() async throws -> CoffeeResponse {
///         try await coffeeAPI.fetchRandomCoffee()
///     }
/// }
/// ```
public protocol CoffeeAPIClientProtocol: Sendable {
    /// Fetches a random coffee image information from the API.
    ///
    /// - Returns: A `CoffeeResponse` containing the image URL.
    /// - Throws: `NetworkError` if the request fails.
    func fetchRandomCoffee() async throws -> CoffeeResponse

    /// Downloads an image from the specified URL.
    ///
    /// - Parameter url: The URL of the image to download.
    /// - Returns: The raw image data.
    /// - Throws: `NetworkError` if the download fails.
    func downloadImage(from url: URL) async throws -> Data
}

// MARK: - Implementation

/// Concrete implementation of `CoffeeAPIClientProtocol` using a generic network service.
///
/// `CoffeeAPIClient` wraps a `NetworkServiceProtocol` implementation and provides
/// Coffee-specific API methods. This separates the domain-specific API logic from
/// the generic networking infrastructure.
///
/// Example:
/// ```swift
/// let networkService = NetworkService(
///     baseURL: CoffeeAPIConfiguration.configuration(for: .production).baseURL
/// )
/// let coffeeAPI = CoffeeAPIClient(networkService: networkService)
///
/// let response = try await coffeeAPI.fetchRandomCoffee()
/// let imageData = try await coffeeAPI.downloadImage(from: response.imageURL!)
/// ```
public actor CoffeeAPIClient: CoffeeAPIClientProtocol {
    private let networkService: NetworkServiceProtocol

    /// Creates a new Coffee API client.
    ///
    /// - Parameter networkService: The network service to use for requests.
    public init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }

    public func fetchRandomCoffee() async throws -> CoffeeResponse {
        try await networkService.request(CoffeeEndpoint.randomCoffee)
    }

    public func downloadImage(from url: URL) async throws -> Data {
        try await networkService.downloadData(from: url)
    }
}
