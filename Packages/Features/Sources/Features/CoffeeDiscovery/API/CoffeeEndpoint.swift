import Foundation
import Core

/// Endpoints for the Coffee API.
///
/// `CoffeeEndpoint` defines all available endpoints for interacting with
/// the Coffee API in a type-safe manner.
///
/// Example:
/// ```swift
/// let endpoint = CoffeeEndpoint.randomCoffee
/// let response: CoffeeResponse = try await networkService.request(endpoint)
/// ```
public enum CoffeeEndpoint: Endpoint {
    /// Fetches a random coffee image URL.
    case randomCoffee

    // MARK: - Endpoint

    public var path: String {
        switch self {
        case .randomCoffee:
            return "/random.json"
        }
    }

    public var method: HTTPMethod {
        .get
    }
}
