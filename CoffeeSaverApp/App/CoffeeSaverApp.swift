import SwiftUI
import SwiftData
import Core
import Features

@main
struct CoffeeSaverApp: App {
    private let modelContainer: ModelContainer
    private let screenFactory: ScreenFactory

    init() {
        do {
            self.modelContainer = try ModelContainer(for: CoffeeImage.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }

        // Initialize dependencies synchronously
        // This automatically selects real or mock services based on testing flag
        let container = ServiceContainer.fromEnvironment()
        self.screenFactory = ScreenFactory(dependencies: container)
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinator(screenFactory: screenFactory)
                .modelContainer(modelContainer)
        }
    }
}
