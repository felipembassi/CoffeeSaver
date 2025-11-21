import SwiftUI

public struct ErrorView: View {
    let message: String
    let retryAction: (() -> Void)?

    public init(
        message: String,
        retryAction: (() -> Void)? = nil
    ) {
        self.message = message
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: Spacing.large) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(Typography.emojiLarge)
                .foregroundStyle(Colors.destructive.opacity(0.7))

            Text(message)
                .font(Typography.headline)
                .multilineTextAlignment(.center)
                .foregroundStyle(Colors.secondaryText)
                .padding(.horizontal, Spacing.medium)

            if let retryAction = retryAction {
                Button(action: retryAction) {
                    Label(Strings.Action.tryAgain, systemImage: "arrow.clockwise")
                        .font(Typography.headline)
                        .padding(.horizontal, Spacing.xxxLarge)
                        .padding(.vertical, Spacing.small)
                        .background(Colors.accent)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(Spacing.medium)
    }
}

// MARK: - Builder Pattern Extensions

public extension ErrorView {
    func onRetry(_ action: @escaping () -> Void) -> Self {
        ErrorView(message: message, retryAction: action)
    }
}
