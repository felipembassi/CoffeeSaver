import SwiftUI

// MARK: - Identifiable Wrapper

public struct AnyIdentifiable: Identifiable, Hashable {
    public let id: String
    public let item: any Identifiable

    public init<T: Identifiable>(_ item: T) {
        self.id = String(describing: item.id)
        self.item = item
    }

    public static func == (lhs: AnyIdentifiable, rhs: AnyIdentifiable) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Coordinator View Modifier

public struct CoordinatorViewModifier<Screen: ScreenType>: ViewModifier {
    let isNested: Bool
    @Bindable var router: Router
    let buildView: (Screen) -> AnyView

    public func body(content: Content) -> some View {
        let wrappedContent = content
            .navigationDestination(for: Screen.self) { screen in
                buildView(screen)
            }
            .sheet(item: $router.sheet, for: Screen.self) { screen in
                buildView(screen)
            }
            .fullScreenCover(item: $router.fullScreenCover, for: Screen.self) { screen in
                buildView(screen)
            }
            .overlay(item: router.overlay, for: Screen.self) { screen in
                buildView(screen)
            }

        if isNested {
            // Nested mode: don't create NavigationStack
            wrappedContent
        } else {
            // Standalone mode: create own NavigationStack
            NavigationStack(path: $router.path) {
                wrappedContent
            }
        }
    }
}

public extension View {
    func coordinatorView<Screen: ScreenType>(
        isNested: Bool,
        router: Router,
        screenType: Screen.Type,
        @ViewBuilder buildView: @escaping (Screen) -> some View
    ) -> some View {
        self.modifier(CoordinatorViewModifier<Screen>(
            isNested: isNested,
            router: router,
            buildView: { screen in AnyView(buildView(screen)) }
        ))
    }
}

// MARK: - Sheet Extension

public extension View {
    @ViewBuilder
    func sheet<Screen>(
        item: Binding<AnyIdentifiable?>,
        for screenType: Screen.Type,
        @ViewBuilder content: @escaping (Screen) -> some View
    ) -> some View {
        let filteredItem = Binding<AnyIdentifiable?>(
            get: {
                guard let item = item.wrappedValue,
                      item.item is Screen else {
                    return nil
                }
                return item
            },
            set: { item.wrappedValue = $0 }
        )

        self.sheet(item: filteredItem) { anyIdentifiable in
            if let typedScreen = anyIdentifiable.item as? Screen {
                content(typedScreen)
            }
        }
    }
}

// MARK: - Full Screen Cover Extension

public extension View {
    @ViewBuilder
    func fullScreenCover<Screen>(
        item: Binding<AnyIdentifiable?>,
        for screenType: Screen.Type,
        @ViewBuilder content: @escaping (Screen) -> some View
    ) -> some View {
        let filteredItem = Binding<AnyIdentifiable?>(
            get: {
                guard let item = item.wrappedValue,
                      item.item is Screen else {
                    return nil
                }
                return item
            },
            set: { item.wrappedValue = $0 }
        )

        self.fullScreenCover(item: filteredItem) { anyIdentifiable in
            if let typedScreen = anyIdentifiable.item as? Screen {
                content(typedScreen)
            }
        }
    }
}

// MARK: - Overlay Extension

public extension View {
    @ViewBuilder
    func overlay<Screen>(
        item: AnyIdentifiable?,
        for screenType: Screen.Type,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping (Screen) -> some View
    ) -> some View {
        self.overlay(alignment: alignment) {
            if let item = item,
               let typedScreen = item.item as? Screen {
                content(typedScreen)
            }
        }
    }
}
