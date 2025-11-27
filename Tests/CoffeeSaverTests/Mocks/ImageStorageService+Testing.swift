import Foundation
@testable import Core

extension ImageStorageService {
    /// Creates a storage service for testing using a temporary directory.
    /// The directory is automatically cleaned up by the system.
    static func forTesting() -> ImageStorageService {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CoffeeSaverTests-\(UUID().uuidString)", isDirectory: true)
        return ImageStorageService(baseDirectory: tempDirectory)
    }
}
