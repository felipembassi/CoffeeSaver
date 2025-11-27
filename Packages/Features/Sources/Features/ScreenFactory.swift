import SwiftUI
import SwiftData
import CommonUI
import Core

/// Factory for creating Feature Coordinators.
///
/// Responsibilities:
/// - Create Feature Coordinators with their specific dependencies
/// - Extract only the services each feature needs from AppDependencies
/// - Keep AppCoordinator unaware of construction details
///
/// Benefits:
/// - Each Feature Coordinator receives only its required dependencies
/// - Single place to manage dependency extraction
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

    /// Create a Feature Coordinator for the given screen type
    /// - Parameters:
    ///   - screen: The screen type to create
    ///   - modelContext: SwiftData model context
    ///   - router: Router for navigation
    /// - Returns: The Feature Coordinator for the screen
    @ViewBuilder
    public func makeScreen(
        for screen: AppScreen,
        modelContext: ModelContext,
        router: Router
    ) -> some View {
        switch screen {
        case .discovery:
            DiscoveryCoordinator(
                dependencies: dependencies,
                modelContext: modelContext,
                router: router
            )

        case .saved:
            SavedCoordinator(
                dependencies: dependencies,
                modelContext: modelContext,
                router: router
            )
        }
    }
}
