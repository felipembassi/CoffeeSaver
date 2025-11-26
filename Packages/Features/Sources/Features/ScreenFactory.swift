import SwiftUI
import SwiftData
import CommonUI
import Core

/// Factory for creating complete screens with all their dependencies.
///
/// Responsibilities:
/// - Build complete screens (View + ViewModel + dependencies)
/// - Create ViewModels with appropriate services
/// - Encapsulate all screen construction logic
/// - Keep AppCoordinator unaware of construction details
///
/// Benefits:
/// - AppCoordinator doesn't need to know about View types or ViewModel construction
/// - Single place to manage all screen creation logic
/// - Compositional: Uses Has<Property> protocols for flexible dependency composition
/// - Easy to add new screens without touching AppCoordinator
/// - Testable: Can inject any AppDependencies implementation
@MainActor
public struct ScreenFactory {
    private let dependencies: AppDependencies

    /// Initialize factory with dependencies
    /// - Parameter dependencies: Dependencies conforming to AppDependencies
    public init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    /// Create a screen for the given screen type
    /// - Parameters:
    ///   - screen: The screen type to create
    ///   - modelContext: SwiftData model context
    ///   - router: Router for navigation
    /// - Returns: The constructed screen view
    @ViewBuilder
    public func makeScreen(
        for screen: AppScreen,
        modelContext: ModelContext,
        router: Router
    ) -> some View {
        switch screen {
        case .discovery:
            DiscoveryScreenBuilder(
                dependencies: dependencies,
                modelContext: modelContext,
                router: router
            )

        case .saved:
            SavedScreenBuilder(
                dependencies: dependencies,
                modelContext: modelContext,
                router: router
            )
        }
    }
}

// MARK: - Screen Builders

/// Helper view that builds the Discovery screen with proper ViewModel lifecycle
private struct DiscoveryScreenBuilder: View {
    let dependencies: AppDependencies
    let modelContext: ModelContext
    let router: Router

    @State private var viewModel: CoffeeDiscoveryViewModel?

    var body: some View {
        Group {
            if let viewModel {
                CoffeeDiscoveryView(viewModel: viewModel, router: router)
            } else {
                ProgressView()
                    .task {
                        let coffeeAPIClient = CoffeeAPIClient(networkService: dependencies.networkService)
                        viewModel = CoffeeDiscoveryViewModel(
                            coffeeAPIClient: coffeeAPIClient,
                            storageService: dependencies.storageService,
                            modelContext: modelContext
                        )
                    }
            }
        }
    }
}

/// Helper view that builds the Saved screen with proper ViewModel lifecycle
private struct SavedScreenBuilder: View {
    let dependencies: AppDependencies
    let modelContext: ModelContext
    let router: Router

    @State private var viewModel: SavedCoffeesViewModel?

    var body: some View {
        Group {
            if let viewModel {
                SavedCoffeesView(viewModel: viewModel, router: router)
            } else {
                ProgressView()
                    .task {
                        viewModel = SavedCoffeesViewModel(
                            storageService: dependencies.storageService,
                            modelContext: modelContext
                        )
                    }
            }
        }
    }
}
