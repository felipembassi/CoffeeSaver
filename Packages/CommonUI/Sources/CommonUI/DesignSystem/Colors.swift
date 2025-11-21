import SwiftUI

public enum Colors {
    // MARK: - Semantic Colors

    public static let primary = Color.green
    public static let secondary = Color.red
    public static let accent = Color.blue

    // MARK: - Action Colors

    public static let like = Color.green
    public static let dislike = Color.red

    // MARK: - Background Colors

    public static let background = Color(uiColor: .systemBackground)
    public static let secondaryBackground = Color(uiColor: .secondarySystemBackground)

    // MARK: - Text Colors

    public static let primaryText = Color.primary
    public static let secondaryText = Color.secondary

    // MARK: - Overlay Colors

    public static func likeOverlay(opacity: Double = 0.3) -> Color {
        like.opacity(opacity)
    }

    public static func dislikeOverlay(opacity: Double = 0.3) -> Color {
        dislike.opacity(opacity)
    }

    public static func shadow(opacity: Double = 0.2) -> Color {
        Color.black.opacity(opacity)
    }

    // MARK: - State Colors

    public static let placeholder = Color.gray.opacity(0.2)
    public static let placeholderIcon = Color.gray
    public static let destructive = Color.red
}
