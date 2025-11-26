import Foundation

// MARK: - Network Configuration

/// Configuration options for network requests.
public struct NetworkConfiguration: Sendable {
    /// Default request timeout interval in seconds.
    public let timeoutInterval: TimeInterval

    /// Default configuration with 30 second timeout.
    public static let `default` = NetworkConfiguration(timeoutInterval: 30)

    /// Configuration for long-running requests (e.g., file uploads).
    public static let longRunning = NetworkConfiguration(timeoutInterval: 120)

    public init(timeoutInterval: TimeInterval) {
        self.timeoutInterval = timeoutInterval
    }
}

/// A simple network service for HTTP requests.
///
/// `NetworkService` provides straightforward network request handling:
/// - Type-safe endpoint-based requests
/// - Automatic JSON decoding
/// - Configurable timeouts
/// - Clear error handling
///
/// Retry logic is intentionally omitted - failed requests should be retried
/// by the user through UI actions (e.g., "Try Again" button).
///
/// Example:
/// ```swift
/// let service = NetworkService(
///     baseURL: URL(string: "https://api.example.com")!
/// )
///
/// let user: User = try await service.request(UserEndpoint.get(id: "123"))
/// ```
public struct NetworkService: NetworkServiceProtocol, Sendable {
    private let urlSession: URLSession
    private let baseURL: URL
    private let configuration: NetworkConfiguration
    private let decoder: JSONDecoder

    /// Creates a new network service.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL for all requests.
    ///   - urlSession: The URL session to use. Defaults to `.shared`.
    ///   - configuration: Network configuration options. Defaults to `.default`.
    ///   - decoder: The JSON decoder for response parsing. Defaults to a new `JSONDecoder`.
    public init(
        baseURL: URL,
        urlSession: URLSession = .shared,
        configuration: NetworkConfiguration = .default,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.baseURL = baseURL
        self.urlSession = urlSession
        self.configuration = configuration
        self.decoder = decoder
    }

    // MARK: - NetworkServiceProtocol

    public func request<T: Decodable & Sendable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await executeRequest(for: endpoint)

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error.localizedDescription)
        }
    }

    public func requestData(_ endpoint: Endpoint) async throws -> Data {
        try await executeRequest(for: endpoint)
    }

    public func downloadData(from url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.get.rawValue
        request.timeoutInterval = configuration.timeoutInterval

        return try await execute(request: request)
    }

    // MARK: - Private Methods

    private func executeRequest(for endpoint: Endpoint) async throws -> Data {
        let request = try buildURLRequest(for: endpoint)
        return try await execute(request: request)
    }

    private func buildURLRequest(for endpoint: Endpoint) throws -> URLRequest {
        guard let url = endpoint.url(baseURL: baseURL) else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body
        request.timeoutInterval = configuration.timeoutInterval

        // Set default headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // Apply custom headers
        endpoint.headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func execute(request: URLRequest) async throws -> Data {
        let (data, response): (Data, URLResponse)

        do {
            (data, response) = try await urlSession.data(for: request)
        } catch {
            throw NetworkError.networkError(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let statusCode = httpResponse.statusCode

        guard (200...299).contains(statusCode) else {
            throw NetworkError.httpError(statusCode: statusCode)
        }

        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        return data
    }
}
