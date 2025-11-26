import SwiftUI
import SwiftData
import Core
import Features

@main
struct CoffeeSaverApp: App {
    private let modelContainer: ModelContainer
    private let screenFactory: ScreenFactory

    init() {
        let isUITesting = ProcessInfo.processInfo.arguments.contains("-UITesting")

        do {
            if isUITesting {
                // Use in-memory storage for UI tests - starts fresh each run
                let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
                self.modelContainer = try ModelContainer(
                    for: CoffeeImage.self,
                    configurations: configuration
                )
            } else {
                self.modelContainer = try ModelContainer(for: CoffeeImage.self)
            }
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
