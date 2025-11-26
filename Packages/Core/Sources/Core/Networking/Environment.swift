import Foundation

// MARK: - App Environment

/// Represents the app's runtime environment.
///
/// Use `AppEnvironment` to configure your app differently based on whether
/// it's running in production or during tests.
///
/// Example:
/// ```swift
/// let environment = AppEnvironment.current
/// let config = CoffeeAPIConfiguration.configuration(for: environment)
/// ```
public enum AppEnvironment: Sendable {
    /// Production environment with real services.
    case production

    /// Testing environment with mock services.
    case testing

    /// Auto-detects the current environment based on build configuration.
    ///
    /// Returns `.testing` when running unit tests (detected via XCTestConfigurationFilePath),
    /// otherwise returns `.production`.
    public static var current: AppEnvironment {
        #if DEBUG
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            return .testing
        }
        #endif
        return .production
    }
}

// MARK: - Coffee API Configuration

/// Configuration for the Coffee API per environment.
///
/// This struct provides environment-specific settings for the Coffee API.
///
/// Example:
/// ```swift
/// let config = CoffeeAPIConfiguration.configuration(for: .production)
/// let service = NetworkService(baseURL: config.baseURL)
/// ```
public struct CoffeeAPIConfiguration: Sendable {
    /// The base URL for the Coffee API.
    public let baseURL: URL

    /// Creates a new configuration with the specified settings.
    ///
    /// - Parameter baseURL: The base URL for the API.
    public init(baseURL: URL) {
        self.baseURL = baseURL
    }

    /// Returns the appropriate configuration for the given environment.
    ///
    /// - Parameter environment: The app environment.
    /// - Returns: The configuration for that environment.
    public static func configuration(for environment: AppEnvironment) -> CoffeeAPIConfiguration {
        switch environment {
        case .production:
            return CoffeeAPIConfiguration(
                // swiftlint:disable:next force_unwrapping
                baseURL: URL(string: "https://coffee.alexflipnote.dev")!
            )
        case .testing:
            return CoffeeAPIConfiguration(
                // swiftlint:disable:next force_unwrapping
                baseURL: URL(string: "https://mock.coffee.test")!
            )
        }
    }
}
