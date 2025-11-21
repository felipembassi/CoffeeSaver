import Testing
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
        #expect(container.apiService is CoffeeAPIService)
        #expect(container.storageService is ImageStorageService)
    }

    @Test("Testing container creates mock services")
    func testingContainerCreatesMockServices() {
        // When creating a testing container
        let container = ServiceContainer.testing()

        // Then it should provide mock service implementations
        #expect(container.apiService is MockCoffeeAPIService)
        #expect(container.storageService is MockImageStorageService)
    }

    @Test("Custom container initialization works")
    func customContainerInitialization() {
        // Given custom service instances
        let apiService = MockCoffeeAPIService()
        let storageService = MockImageStorageService()

        // When creating a container with custom services
        let container = ServiceContainer(
            apiService: apiService,
            storageService: storageService
        )

        // Then it should use the provided services
        #expect(container.apiService is MockCoffeeAPIService)
        #expect(container.storageService is MockImageStorageService)
    }

    // MARK: - Has<Property> Protocol Conformance

    @Test("ServiceContainer conforms to HasAPIService")
    func serviceContainerConformsToHasAPIService() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When treating it as HasAPIService
        let hasAPI: any HasAPIService = container

        // Then it should provide API service access
        #expect(hasAPI.apiService is MockCoffeeAPIService)
    }

    @Test("ServiceContainer conforms to HasStorageService")
    func serviceContainerConformsToHasStorageService() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When treating it as HasStorageService
        let hasStorage: any HasStorageService = container

        // Then it should provide storage service access
        #expect(hasStorage.storageService is MockImageStorageService)
    }

    @Test("ServiceContainer conforms to AppDependencies composition")
    func serviceContainerConformsToAppDependencies() {
        // Given a service container
        let container = ServiceContainer.testing()

        // When treating it as AppDependencies (composition of all Has protocols)
        let dependencies: any AppDependencies = container

        // Then it should provide access to all services
        #expect(dependencies.apiService is MockCoffeeAPIService)
        #expect(dependencies.storageService is MockImageStorageService)
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
        #expect(container.apiService is MockCoffeeAPIService)
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
        #expect(deps.apiService is MockCoffeeAPIService)
    }

    // MARK: - Service Access

    @Test("API service is accessible through container")
    func apiServiceIsAccessible() {
        // Given a testing container
        let container = ServiceContainer.testing()

        // When accessing the API service
        let apiService = container.apiService

        // Then it should be the mock implementation
        #expect(apiService is MockCoffeeAPIService)
    }

    @Test("Storage service is accessible through container")
    func storageServiceIsAccessible() {
        // Given a testing container
        let container = ServiceContainer.testing()

        // When accessing the storage service
        let storageService = container.storageService

        // Then it should be the mock implementation
        #expect(storageService is MockImageStorageService)
    }

    // MARK: - Test Helper: Mock AppDependencies

    @Test("Custom mock dependencies can be created")
    func customMockDependenciesCanBeCreated() {
        // Given custom mock implementations
        struct MockDependencies: AppDependencies {
            let apiService: CoffeeAPIServiceProtocol = MockCoffeeAPIService()
            let storageService: ImageStorageServiceProtocol = MockImageStorageService()
        }

        // When creating mock dependencies
        let mocks = MockDependencies()

        // Then they should conform to AppDependencies
        let dependencies: any AppDependencies = mocks
        #expect(dependencies.apiService is MockCoffeeAPIService)
        #expect(dependencies.storageService is MockImageStorageService)
    }
}
