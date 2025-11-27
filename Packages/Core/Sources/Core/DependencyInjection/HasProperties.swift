import Foundation

// MARK: - Has<Property> Protocols

/// Protocol for types that provide access to a generic network service.
///
/// Use this protocol to declare dependencies on the network service without
/// coupling to the full container implementation.
///
/// Example:
/// ```swift
/// class MyViewModel {
///     typealias Dependencies = HasNetworkService
///
///     init(dependencies: Dependencies) {
///         self.networkService = dependencies.networkService
///     }
/// }
/// ```
public protocol HasNetworkService {
    var networkService: NetworkServiceProtocol { get }
}

/// Protocol for types that provide access to the Image Storage service.
///
/// Use this protocol to declare dependencies on the storage service without
/// coupling to the full container implementation.
///
/// Example:
/// ```swift
/// class MyViewModel {
///     typealias Dependencies = HasStorageService
///
///     init(dependencies: Dependencies) {
///         self.storageService = dependencies.storageService
///     }
/// }
/// ```
public protocol HasStorageService {
    var storageService: ImageStorageServiceProtocol { get }
}

/// Protocol for types that provide access to the Network Reachability service.
///
/// Use this protocol to declare dependencies on the reachability service without
/// coupling to the full container implementation.
///
/// Example:
/// ```swift
/// class MyViewModel {
///     typealias Dependencies = HasReachability
///
///     init(dependencies: Dependencies) {
///         self.reachability = dependencies.reachability
///     }
/// }
/// ```
public protocol HasReachability {
    var reachability: NetworkReachabilityProtocol { get }
}

// MARK: - Convenience Typealiases

/// Convenience typealias for components that need all app dependencies.
///
/// Example:
/// ```swift
/// class CoffeeViewModel {
///     typealias Dependencies = AppDependencies
///
///     init(dependencies: Dependencies, modelContext: ModelContext) {
///         // Access both services
///     }
/// }
/// ```
public typealias AppDependencies = HasNetworkService & HasStorageService & HasReachability & Sendable
