import Foundation
import SwiftData

@Model
public final class CoffeeImage {
    @Attribute(.unique) public var id: UUID
    public var remoteURL: String
    public var localPath: String
    public var thumbnailPath: String?
    public var dateSaved: Date

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
