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
public typealias AppDependencies = HasNetworkService & HasStorageService & Sendable
