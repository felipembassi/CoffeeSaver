import Foundation

/// Protocol defining access to all application services.
///
/// This protocol provides a centralized way to access services without
/// requiring every consumer to know about all service types upfront.
///
/// Benefits:
/// - Scalable: Add new services without changing consumers
/// - Testable: Easy to create mock implementations
/// - Decoupled: Consumers depend on protocol, not concrete types
public protocol ServiceProvider {
    /// Service for fetching coffee data from the API
    var apiService: CoffeeAPIServiceProtocol { get }

    /// Service for storing and retrieving coffee images
    var storageService: ImageStorageServiceProtocol { get }
}
