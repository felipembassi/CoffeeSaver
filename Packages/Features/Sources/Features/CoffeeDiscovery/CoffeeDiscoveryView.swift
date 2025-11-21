import SwiftUI
import CommonUI

public struct CoffeeDiscoveryView: View {
    @State var viewModel: CoffeeDiscoveryViewModel
    let router: Router

    public init(viewModel: CoffeeDiscoveryViewModel, router: Router) {
        self.viewModel = viewModel
        self.router = router
    }

    public var body: some View {
        VStack(spacing: Spacing.large) {
            headerSection
                .padding(.top, Spacing.xSmall)

            Spacer(minLength: Spacing.minVerticalSpace)

            mainContent

            Spacer(minLength: Spacing.minVerticalSpace)
        }
        .padding(.horizontal, Spacing.cardPadding)
        .safeAreaInset(edge: .bottom) {
            actionButtons
                .padding(.vertical, Spacing.medium)
        }
        .navigationTitle(Strings.Navigation.discover)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if case .idle = viewModel.loadingState {
                await viewModel.loadRandomCoffee()
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: Spacing.xSmall) {
            Text(Strings.Discovery.emoji)
                .font(Typography.emojiLarge)

            Text(Strings.Discovery.subtitle)
                .font(Typography.headline)
                .foregroundStyle(Colors.secondaryText)
        }
        .padding(.top)
    }

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.loadingState {
        case .idle, .loading:
            LoadingView(message: Strings.Discovery.loading)
                .frame(maxWidth: .infinity, maxHeight: 500)
                .accessibilityIdentifier("discovery-loading")

        case .loaded(let image):
            SwipeableCardView()
                .cardImage(image)
                .cardStyle(.tinder)
                .onSave {
                    Task {
                        await viewModel.saveCoffee()
                    }
                }
                .onSkip {
                    Task {
                        await viewModel.skipCoffee()
                    }
                }
                .accessibilityIdentifier("coffee-card")
                .accessibilityLabel("coffee-image-\(viewModel.currentCoffeeURL ?? "unknown")")

        case .error(let error):
            ErrorView(
                message: error.localizedDescription,
                retryAction: {
                    Task {
                        await viewModel.loadRandomCoffee()
                    }
                }
            )
            .frame(maxWidth: .infinity, maxHeight: 500)
            .accessibilityIdentifier("discovery-error")
        }
    }

    private var actionButtons: some View {
        HStack(spacing: Spacing.buttonSpacing) {
            Button(action: {
                Task {
                    await viewModel.skipCoffee()
                }
            }) {
                Image(systemName: "xmark")
                    .font(Typography.iconMediumFont)
                    .foregroundStyle(Colors.dislike)
                    .frame(width: Spacing.actionButtonSize, height: Spacing.actionButtonSize)
                    .background(Circle().fill(Colors.dislikeOverlay(opacity: 0.1)))
            }
            .disabled(viewModel.isLoading || viewModel.isSaving)
            .accessibilityIdentifier("skip-button")

            Button(action: {
                Task {
                    await viewModel.saveCoffee()
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(Typography.iconMediumFont)
                    .foregroundStyle(Colors.like)
                    .frame(width: Spacing.actionButtonSize, height: Spacing.actionButtonSize)
                    .background(Circle().fill(Colors.likeOverlay(opacity: 0.1)))
            }
            .disabled(viewModel.isLoading || viewModel.isSaving)
            .accessibilityIdentifier("like-button")
        }
    }
}
