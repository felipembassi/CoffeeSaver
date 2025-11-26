import Foundation

/// Main dependency injection container conforming to Has<Property> protocols.
///
/// This container provides a clean Has<Property> based API for accessing services.
/// It uses `AppEnvironment` to automatically configure services based on the
/// runtime environment (production vs testing).
///
/// Key principles:
/// - No singletons: Each container is an independent instance
/// - Compositional: Conforms to individual Has protocols
/// - Environment-aware: Auto-detects test vs production mode
/// - Generic networking: Uses NetworkService for all API calls
///
/// Usage:
/// ```swift
/// // Create container with automatic environment detection
/// let container = ServiceContainer.fromEnvironment()
///
/// // Access services via Has protocols
/// let networkService = container.networkService
/// ```
public struct ServiceContainer: AppDependencies, Sendable {
    public let networkService: NetworkServiceProtocol
    public let storageService: ImageStorageServiceProtocol

    // MARK: - Initialization

    /// Create a container with environment-aware services.
    ///
    /// This automatically detects if running in test mode and creates appropriate services.
    /// Uses `AppEnvironment.current` for environment detection.
    public static func fromEnvironment() -> ServiceContainer {
        let environment = AppEnvironment.current

        // Check for UI testing override
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            return testing()
        }

        switch environment {
        case .production:
            return production()
        case .testing:
            return testing()
        }
    }

    /// Create a production container with real services.
    public static func production() -> ServiceContainer {
        let config = CoffeeAPIConfiguration.configuration(for: .production)

        return ServiceContainer(
            networkService: NetworkService(baseURL: config.baseURL),
            storageService: ImageStorageService()
        )
    }

    /// Create a testing container with mock network and real storage (using temp directory).
    ///
    /// This uses the real `ImageStorageService` with a temporary directory,
    /// ensuring tests exercise the real code paths including priority handling.
    public static func testing() -> ServiceContainer {
        ServiceContainer(
            networkService: MockNetworkService(),
            storageService: ImageStorageService.forTesting()
        )
    }

    /// Create a container with specific services.
    ///
    /// - Parameters:
    ///   - networkService: The network service to use for API calls.
    ///   - storageService: The storage service for image persistence.
    public init(
        networkService: NetworkServiceProtocol,
        storageService: ImageStorageServiceProtocol
    ) {
        self.networkService = networkService
        self.storageService = storageService
    }
}

