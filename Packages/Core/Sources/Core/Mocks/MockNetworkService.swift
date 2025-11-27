import Foundation
import UIKit

/// A lightweight mock implementation of `NetworkServiceProtocol` for testing.
///
/// This mock returns controlled responses. Configure `nextResponseJSON` for decoded
/// responses or `nextData` for raw data responses.
///
/// Example:
/// ```swift
/// let mock = MockNetworkService(
///     nextResponseJSON: #"{"file": "https://example.com/coffee.jpg"}"#
/// )
///
/// let client = CoffeeAPIClient(networkService: mock)
/// let response = try await client.fetchRandomCoffee()
/// ```
///
/// Note: This is a struct with immutable configuration for thread safety.
/// Create a new instance with different values if you need different behavior.
public struct MockNetworkService: NetworkServiceProtocol, Sendable {
    /// JSON string to return for `request<T>` calls. Will be decoded to T.
    public let nextResponseJSON: String?

    /// Raw data to return for `requestData` and `downloadData` calls.
    /// If nil, generates default image data lazily.
    public let nextData: Data?

    /// If set, all requests will throw this error.
    public let errorToThrow: NetworkError?

    public init(
        nextResponseJSON: String? = nil,
        nextData: Data? = nil,
        errorToThrow: NetworkError? = nil
    ) {
        self.nextResponseJSON = nextResponseJSON
        self.nextData = nextData
        self.errorToThrow = errorToThrow
    }

    /// Creates default image data for mock responses.
    /// Called lazily to ensure graphics context is available.
    @MainActor
    private static func createDefaultImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 100))
        let image = renderer.image { context in
            UIColor.brown.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 100, height: 100))
        }
        return image.jpegData(compressionQuality: 0.8) ?? Data()
    }

    // MARK: - NetworkServiceProtocol

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        if let error = errorToThrow {
            throw error
        }

        // Use provided JSON or generate default coffee response
        let json = nextResponseJSON ?? #"{"file": "https://mock.coffee.api/\#(UUID().uuidString).jpg"}"#
        guard let data = json.data(using: .utf8) else {
            throw NetworkError.noData
        }

        return try JSONDecoder().decode(T.self, from: data)
    }

    public func requestData(_ endpoint: Endpoint) async throws -> Data {
        if let error = errorToThrow {
            throw error
        }

        if let data = nextData {
            return data
        }

        // Generate default image data lazily on main thread
        return await Self.createDefaultImageData()
    }

    public func downloadData(from url: URL) async throws -> Data {
        if let error = errorToThrow {
            throw error
        }

        if let data = nextData {
            return data
        }

        // Generate default image data lazily on main thread
        return await Self.createDefaultImageData()
    }
}
