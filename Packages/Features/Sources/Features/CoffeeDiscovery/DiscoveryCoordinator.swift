import SwiftUI
import SwiftData
import Core
import CommonUI

/// Coordinator for the Discovery feature.
///
/// Responsibilities:
/// - Owns the ViewModel lifecycle via `@State`
/// - Receives only the dependencies this feature needs
/// - Handles feature-level navigation (sheets, alerts, sub-screens)
/// - Creates and configures the View
struct DiscoveryCoordinator: View {
    /// Dependencies required by this Coordinator (ViewModel deps + network for API client).
    typealias Dependencies = CoffeeDiscoveryViewModel.Dependencies & HasNetworkService

    // Dependencies
    private let dependencies: Dependencies
    private let modelContext: ModelContext
    private let router: Router

    // ViewModel owned by coordinator - persists across view updates
    @State private var viewModel: CoffeeDiscoveryViewModel?

    init(
        dependencies: Dependencies,
        modelContext: ModelContext,
        router: Router
    ) {
        self.dependencies = dependencies
        self.modelContext = modelContext
        self.router = router
    }

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
                            dependencies: dependencies,
                            modelContext: modelContext
                        )
                    }
            }
        }
    }
}
