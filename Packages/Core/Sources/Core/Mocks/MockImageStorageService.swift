import Foundation
import UIKit

/// Mock image storage service for UI testing
/// Stores images in memory instead of file system
public actor MockImageStorageService: ImageStorageServiceProtocol {
    private var storage: [UUID: Data] = [:]
    private var thumbnails: [UUID: Data] = [:]

    public init() {}

    public func saveImage(_ data: Data, withID id: UUID) async throws -> String {
        storage[id] = data
        return "/mock/images/\(id).jpg"
    }

    public func loadImage(from path: String) async throws -> UIImage {
        // Extract ID from path if possible, otherwise create a test image
        let testSize = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(testSize)
        UIColor.systemBrown.setFill()
        UIRectFill(CGRect(origin: .zero, size: testSize))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    public func deleteImage(at path: String) async throws {
        // No-op for mock - images stored in memory
    }

    public func generateThumbnail(from data: Data, withID id: UUID) async throws -> String {
        // Create a small thumbnail
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        UIColor.systemOrange.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        thumbnails[id] = image.pngData()
        return "/mock/thumbnails/\(id)_thumb.jpg"
    }
}
