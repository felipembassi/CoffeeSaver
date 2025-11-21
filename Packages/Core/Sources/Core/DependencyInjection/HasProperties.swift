import Foundation

// MARK: - Has<Property> Protocols

/// Protocol for types that provide access to the Coffee API service.
///
/// Use this protocol to declare dependencies on the API service without
/// coupling to the full container implementation.
///
/// Example:
/// ```swift
/// class MyViewModel {
///     typealias Dependencies = HasAPIService
///
///     init(dependencies: Dependencies) {
///         self.apiService = dependencies.apiService
///     }
/// }
/// ```
public protocol HasAPIService {
    var apiService: CoffeeAPIServiceProtocol { get }
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
public typealias AppDependencies = HasAPIService & HasStorageService & Sendable
