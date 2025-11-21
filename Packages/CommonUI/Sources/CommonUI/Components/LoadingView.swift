import SwiftUI

public struct LoadingView: View {
    let message: String?

    public init(message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: Spacing.large) {
            ProgressView()
                .scaleEffect(1.5)

            if let message = message {
                Text(message)
                    .font(Typography.headline)
                    .foregroundStyle(Colors.secondaryText)
            }
        }
        .padding(Spacing.medium)
    }
}

// MARK: - Builder Pattern Extensions

public extension LoadingView {
    func message(_ text: String) -> Self {
        LoadingView(message: text)
    }
}
