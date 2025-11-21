import Foundation

public enum Dimensions {
    // MARK: - Shadow

    public static let shadowRadius: CGFloat = 10
    public static let shadowX: CGFloat = 0
    public static let shadowY: CGFloat = 5

    // MARK: - Card

    public static let cardAspectRatio: CGFloat = 5.0 / 7.0

    // MARK: - Image Processing

    public static let maxImageDimension: CGFloat = 1200
    public static let thumbnailSize = CGSize(width: 300, height: 300)

    // MARK: - Animation

    public static let swipeOffscreenDistance: CGFloat = 500
    public static let rotationDivider: CGFloat = 20
    public static let maxRotation: CGFloat = 15

    // MARK: - Compression

    public static let imageQuality: CGFloat = 0.9
    public static let thumbnailQuality: CGFloat = 0.7
    public static let storageQuality: CGFloat = 0.8
}
