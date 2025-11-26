import Foundation

/// Protocol defining a generic network service for making HTTP requests.
///
/// `NetworkServiceProtocol` provides a type-safe interface for making network requests
/// using the `Endpoint` protocol. It supports both JSON-decoded responses and raw data
/// responses, making it suitable for various use cases like API calls and file downloads.
///
/// Example:
/// ```swift
/// // Make a JSON request
/// let user: User = try await networkService.request(UserEndpoint.getUser(id: "123"))
///
/// // Download raw data from an absolute URL (e.g., images)
/// let imageData = try await networkService.downloadData(from: imageURL)
/// ```
///
/// Conforming types should handle:
/// - URL construction from endpoints
/// - HTTP request execution
/// - Response validation
/// - JSON decoding
/// - Error handling
/// - Retry logic (optional)
public protocol NetworkServiceProtocol: Sendable {
    /// Makes a network request and decodes the response as the specified type.
    ///
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: The decoded response of type `T`.
    /// - Throws: `NetworkError` if the request fails or decoding fails.
    func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T

    /// Makes a network request and returns the raw response data.
    ///
    /// Use this method for downloading binary data like images or files
    /// that don't need JSON decoding.
    ///
    /// - Parameter endpoint: The endpoint to request.
    /// - Returns: The raw response data.
    /// - Throws: `NetworkError` if the request fails.
    func requestData(_ endpoint: Endpoint) async throws -> Data

    /// Downloads data from an absolute URL.
    ///
    /// Use this method for downloading resources from external URLs
    /// that are not relative to the service's base URL.
    ///
    /// - Parameter url: The absolute URL to download from.
    /// - Returns: The raw response data.
    /// - Throws: `NetworkError` if the download fails.
    func downloadData(from url: URL) async throws -> Data
}
