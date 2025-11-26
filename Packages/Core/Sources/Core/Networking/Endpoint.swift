import Foundation

// MARK: - HTTP Method

/// HTTP methods supported by the networking layer.
public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

// MARK: - Endpoint Protocol

/// Protocol defining an API endpoint with type-safe request components.
///
/// Conform to this protocol to define your API endpoints in a structured,
/// type-safe manner. Each endpoint specifies its path, HTTP method, headers,
/// query parameters, and request body.
///
/// Example:
/// ```swift
/// enum UserEndpoint: Endpoint {
///     case getUser(id: String)
///     case createUser(name: String, email: String)
///
///     var path: String {
///         switch self {
///         case .getUser(let id): return "/users/\(id)"
///         case .createUser: return "/users"
///         }
///     }
///
///     var method: HTTPMethod {
///         switch self {
///         case .getUser: return .get
///         case .createUser: return .post
///         }
///     }
/// }
/// ```
public protocol Endpoint: Sendable {
    /// The path component of the URL (e.g., "/users/123").
    var path: String { get }

    /// The HTTP method for this endpoint.
    var method: HTTPMethod { get }

    /// Optional HTTP headers to include with the request.
    var headers: [String: String]? { get }

    /// Optional query items to append to the URL.
    var queryItems: [URLQueryItem]? { get }

    /// Optional request body data.
    var body: Data? { get }

    /// Builds a complete URL from the endpoint and a base URL.
    ///
    /// - Parameter baseURL: The base URL to combine with the endpoint path.
    /// - Returns: The complete URL, or nil if construction fails.
    func url(baseURL: URL) -> URL?
}

// MARK: - Default Implementations

public extension Endpoint {
    /// Default implementation returns nil (no custom headers).
    var headers: [String: String]? { nil }

    /// Default implementation returns nil (no query parameters).
    var queryItems: [URLQueryItem]? { nil }

    /// Default implementation returns nil (no request body).
    var body: Data? { nil }
}

// MARK: - URL Building

public extension Endpoint {
    func url(baseURL: URL) -> URL? {
        var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: true
        )

        if let queryItems = queryItems, !queryItems.isEmpty {
            components?.queryItems = queryItems
        }

        return components?.url
    }
}

