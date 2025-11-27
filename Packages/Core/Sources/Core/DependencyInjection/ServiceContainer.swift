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
    public let reachability: NetworkReachabilityProtocol

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
    ///
    /// Note: Network reachability monitoring starts automatically when you first
    /// access the `connectivityStream` or `isConnected` properties.
    public static func production() -> ServiceContainer {
        let config = CoffeeAPIConfiguration.configuration(for: .production)

        let reachability = NetworkReachability()

        // Start monitoring immediately in a detached task.
        // The task is intentionally not stored as the reachability actor
        // manages its own lifecycle and will stop monitoring on deinit.
        Task.detached { await reachability.startMonitoring() }

        return ServiceContainer(
            networkService: NetworkService(baseURL: config.baseURL),
            storageService: ImageStorageService(),
            reachability: reachability
        )
    }

    /// Create a testing container with mock network and real storage (using temp directory).
    ///
    /// This uses the real `ImageStorageService` with a temporary directory,
    /// ensuring tests exercise the real code paths including priority handling.
    public static func testing() -> ServiceContainer {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CoffeeSaverTests-\(UUID().uuidString)", isDirectory: true)

        return ServiceContainer(
            networkService: MockNetworkService(),
            storageService: ImageStorageService(baseDirectory: tempDirectory),
            reachability: MockNetworkReachability()
        )
    }

    /// Create a container with specific services.
    ///
    /// - Parameters:
    ///   - networkService: The network service to use for API calls.
    ///   - storageService: The storage service for image persistence.
    ///   - reachability: The reachability service for network connectivity monitoring.
    public init(
        networkService: NetworkServiceProtocol,
        storageService: ImageStorageServiceProtocol,
        reachability: NetworkReachabilityProtocol
    ) {
        self.networkService = networkService
        self.storageService = storageService
        self.reachability = reachability
    }
}

