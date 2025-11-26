import Foundation

public enum NetworkError: Error, LocalizedError, Sendable {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(String)
    case networkError(String)
    case noData
    case imageConversionFailed
    case noConnection
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid"
        case .invalidResponse:
            return "The server response was invalid"
        case .httpError(let statusCode):
            return "HTTP error with status code: \(statusCode)"
        case .decodingError(let message):
            return "Failed to decode the response: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .noData:
            return "No data received from the server"
        case .imageConversionFailed:
            return "Failed to convert data to image"
        case .noConnection:
            return "No internet connection"
        case .cancelled:
            return "Request was cancelled"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .invalidURL, .invalidResponse, .decodingError:
            return "Please try again later or contact support"
        case .httpError:
            return "Please check your connection and try again"
        case .networkError, .noConnection:
            return "Please check your internet connection"
        case .noData:
            return "Please try again"
        case .imageConversionFailed:
            return "The image format may be unsupported"
        case .cancelled:
            return nil
        }
    }
}
