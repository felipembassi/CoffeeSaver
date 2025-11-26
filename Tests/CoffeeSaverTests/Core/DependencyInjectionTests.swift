import Testing
import Foundation
@testable import Core

/// Unit tests for the Has<Property> dependency injection pattern.
///
/// These tests verify that:
/// - ServiceContainer creates appropriate services for production and testing
/// - AppDependencies composition works correctly
/// - Custom container initialization works as expected
/// - Services are accessible through Has<Property> protocols
@Suite("Dependency Injection Tests")
struct DependencyInjectionTests {

    // MARK: - ServiceContainer Factory Methods

    @Test("Production container creates real services")
    func productionContainerCreatesRealServices() {
        // When creating a production container
        let container = ServiceContainer.production()

        // Then it should provide real service implementations
        #expect(container.networkService is NetworkService)
        #expect(container.storageService is ImageStorageService)
    }

    @Test("Testing container creates appropriate services")
    func testingContainerCreatesAppropriateServices() {
        // When creating a testing container
        let container = ServiceContainer.testing()

        // Then it should provide mock network and real storage (with temp directory)
        #expect(container.networkService is MockNetworkService)
        #expect(container.storageService is ImageStorageService)
    }

    @Test("Custom container initialization works")
    func customContainerInitialization() {
        // Given custom service instances
        let networkService = MockNetworkService()
        let storageService = ImageStorageService.forTesting()

        // When creating a container with custom services
        let container = ServiceContainer(
            networkService: networkService,
            storageService: storageService
        )

        // Then it should use the provided services
        #expect(container.networkService is MockNetworkService)
        #expect(container.storageService is ImageStorageService)
    }

    // MARK: - Has<Property> Protocol Conformance

    @Test("ServiceContainer conforms to HasNetworkService")
    func serviceContainerConformsToHasNetworkService() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When treating it as HasNetworkService
        let hasNetwork: any HasNetworkService = container

        // Then it should provide network service access
        #expect(hasNetwork.networkService is MockNetworkService)
    }

    @Test("ServiceContainer conforms to HasStorageService")
    func serviceContainerConformsToHasStorageService() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When treating it as HasStorageService
        let hasStorage: any HasStorageService = container

        // Then it should provide storage service access
        #expect(hasStorage.storageService is ImageStorageService)
    }

    @Test("ServiceContainer conforms to AppDependencies composition")
    func serviceContainerConformsToAppDependencies() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When treating it as AppDependencies (composition of all Has protocols)
        let dependencies: any AppDependencies = container

        // Then it should provide access to all services
        #expect(dependencies.networkService is MockNetworkService)
        #expect(dependencies.storageService is ImageStorageService)
    }

    // MARK: - Sendable Conformance

    // Note: Sendable conformance is verified at compile-time.
    // These tests verify that the types compile with Sendable constraints.

    @Test("ServiceContainer is Sendable - compiles with Sendable constraint")
    func serviceContainerIsSendable() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When using it in a Sendable context (compile-time check)
        let _: any Sendable = container

        // Then it compiles successfully (this test passing means Sendable works)
        #expect(container.networkService is MockNetworkService)
    }

    @Test("AppDependencies can be used across concurrency boundaries")
    func appDependenciesCanCrossActorBoundaries() async {
        // Given a service container
        let container = ServiceContainer.testing()

        // When using it as AppDependencies in an async context
        let dependencies: any AppDependencies = container

        // Then it can be passed to async functions (Sendable requirement)
        await useDependencies(dependencies)
    }

    // Helper function that requires Sendable parameter
    private func useDependencies(_ deps: any AppDependencies) async {
        #expect(deps.networkService is MockNetworkService)
    }

    // MARK: - Service Access

    @Test("Network service is accessible through container")
    func networkServiceIsAccessible() {
        // Given a testing container
        let container = ServiceContainer.testing()

        // When accessing the network service
        let networkService = container.networkService

        // Then it should be the mock implementation
        #expect(networkService is MockNetworkService)
    }

    @Test("Storage service is accessible through container")
    func storageServiceIsAccessible() {
        // Given a testing container
        let container = ServiceContainer.testing()

        // When accessing the storage service
        let storageService = container.storageService

        // Then it should be the real implementation (with temp directory)
        #expect(storageService is ImageStorageService)
    }

    // MARK: - Test Helper: Mock AppDependencies

    @Test("Custom mock dependencies can be created")
    func customMockDependenciesCanBeCreated() {
        // Given custom mock implementations
        struct MockDependencies: AppDependencies {
            let networkService: NetworkServiceProtocol = MockNetworkService()
            let storageService: ImageStorageServiceProtocol = ImageStorageService.forTesting()
        }

        // When creating mock dependencies
        let mocks = MockDependencies()

        // Then they should conform to AppDependencies
        let dependencies: any AppDependencies = mocks
        #expect(dependencies.networkService is MockNetworkService)
        #expect(dependencies.storageService is ImageStorageService)
    }

    // MARK: - Environment Configuration Tests

    @Test("Production configuration has correct base URL")
    func productionConfigHasCorrectBaseURL() {
        // When getting production configuration
        let config = CoffeeAPIConfiguration.configuration(for: .production)

        // Then it should have the correct base URL
        #expect(config.baseURL.absoluteString == "https://coffee.alexflipnote.dev")
    }

    @Test("Testing configuration has correct base URL")
    func testingConfigHasCorrectBaseURL() {
        // When getting testing configuration
        let config = CoffeeAPIConfiguration.configuration(for: .testing)

        // Then it should have the mock base URL
        #expect(config.baseURL.absoluteString == "https://mock.coffee.test")
    }
}
