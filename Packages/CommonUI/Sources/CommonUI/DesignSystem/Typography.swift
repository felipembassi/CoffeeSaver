import SwiftUI

public enum Typography {
    // MARK: - Font Sizes

    public static let largeEmoji: CGFloat = 60
    public static let iconLarge: CGFloat = 80
    public static let iconMedium: CGFloat = 30

    // MARK: - Text Styles

    public static let title = Font.title
    public static let title2 = Font.title2
    public static let headline = Font.headline
    public static let body = Font.body
    public static let caption = Font.caption

    // MARK: - Custom Styles

    public static func system(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    public static let emojiLarge = Font.system(size: largeEmoji)
    public static let iconLargeFont = Font.system(size: iconLarge)
    public static let iconMediumFont = Font.system(size: iconMedium)
}
