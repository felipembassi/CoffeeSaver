import SwiftUI
import SwiftData
import CommonUI
import Features

struct AppCoordinator: View, Coordinator {
    typealias Screen = AppScreen
    typealias Result = Void

    @State var router: Router
    let onFinish: ((Result) -> Void)?
    @Environment(\.modelContext) private var modelContext

    private let screenFactory: ScreenFactory

    init(
        screenFactory: ScreenFactory,
        onFinish: ((Result) -> Void)? = nil
    ) {
        self.screenFactory = screenFactory
        self.onFinish = onFinish
        self.router = Router(rootScreen: AppScreen.discovery)
    }

    var body: some View {
        TabView {
            buildView(for: .discovery)
                .tabItem {
                    Label(Strings.Tab.discover, systemImage: "heart.circle.fill")
                }

            buildView(for: .saved)
                .tabItem {
                    Label(Strings.Tab.saved, systemImage: "square.grid.2x2.fill")
                }
        }
    }

    @MainActor
    @ViewBuilder
    func buildView(for screen: Screen) -> some View {
        NavigationStack {
            screenFactory.makeScreen(
                for: screen,
                modelContext: modelContext,
                router: router
            )
        }
    }
}
