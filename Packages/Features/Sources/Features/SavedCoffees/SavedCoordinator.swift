import SwiftUI
import SwiftData
import Core
import CommonUI

/// Coordinator for the Saved Coffees feature.
///
/// Responsibilities:
/// - Owns the ViewModel lifecycle via `@State`
/// - Receives only the dependencies this feature needs
/// - Handles feature-level navigation (sheets, alerts, sub-screens)
/// - Creates and configures the View
struct SavedCoordinator: View {
    /// Dependencies required by this Coordinator (same as ViewModel).
    typealias Dependencies = SavedCoffeesViewModel.Dependencies

    // Dependencies
    private let dependencies: Dependencies
    private let modelContext: ModelContext
    private let router: Router

    // ViewModel owned by coordinator - persists across view updates
    @State private var viewModel: SavedCoffeesViewModel?

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
                SavedCoffeesView(viewModel: viewModel, router: router)
            } else {
                ProgressView()
                    .task {
                        viewModel = SavedCoffeesViewModel(
                            dependencies: dependencies,
                            modelContext: modelContext
                        )
                    }
            }
        }
    }
}
