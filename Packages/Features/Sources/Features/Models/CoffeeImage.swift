import Foundation
import SwiftData

/// A saved coffee image with local storage paths.
///
/// This model stores metadata about saved coffee images including
/// remote URL, local file paths, and save date.
@Model
public final class CoffeeImage {
    /// Unique identifier for the coffee image.
    @Attribute(.unique) public var id: UUID

    /// The original remote URL where the image was downloaded from.
    public var remoteURL: String

    /// Local file path to the full-size image.
    public var localPath: String

    /// Local file path to the thumbnail image.
    public var thumbnailPath: String?

    /// Date when the image was saved.
    @Attribute(.spotlight) public var dateSaved: Date

    public init(
        id: UUID = UUID(),
        remoteURL: String,
        localPath: String,
        thumbnailPath: String? = nil,
        dateSaved: Date = Date()
    ) {
        self.id = id
        self.remoteURL = remoteURL
        self.localPath = localPath
        self.thumbnailPath = thumbnailPath
        self.dateSaved = dateSaved
    }
}
