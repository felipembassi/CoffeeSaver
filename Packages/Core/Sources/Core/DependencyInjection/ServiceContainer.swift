import Foundation

/// Main dependency injection container conforming to Has<Property> protocols.
///
/// This container uses `DependencyRegistry` internally for service resolution
/// and provides a clean Has<Property> based API for accessing services.
///
/// Key principles:
/// - No singletons: Each container is an independent instance
/// - Compositional: Conforms to individual Has protocols
/// - Registry-backed: Uses DependencyRegistry for flexible scoping
/// - Environment-aware: Auto-detects test vs production mode
///
/// Usage:
/// ```swift
/// // Create container with automatic environment detection
/// let container = await ServiceContainer.fromEnvironment()
///
/// // Access services via Has protocols
/// let api = try await container.apiService
/// ```
public struct ServiceContainer: AppDependencies, Sendable {
    public let apiService: CoffeeAPIServiceProtocol
    public let storageService: ImageStorageServiceProtocol

    // MARK: - Initialization

    /// Create a container with environment-aware services.
    ///
    /// This automatically detects if running in test mode and creates appropriate services.
    public static func fromEnvironment() -> ServiceContainer {
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            return testing()
        } else {
            return production()
        }
    }

    /// Create a production container with real services.
    public static func production() -> ServiceContainer {
        ServiceContainer(
            apiService: CoffeeAPIService(urlSession: .shared),
            storageService: ImageStorageService()
        )
    }

    /// Create a testing container with mock services.
    public static func testing() -> ServiceContainer {
        ServiceContainer(
            apiService: MockCoffeeAPIService(),
            storageService: MockImageStorageService()
        )
    }

    /// Create a container with specific services.
    public init(
        apiService: CoffeeAPIServiceProtocol,
        storageService: ImageStorageServiceProtocol
    ) {
        self.apiService = apiService
        self.storageService = storageService
    }
}

