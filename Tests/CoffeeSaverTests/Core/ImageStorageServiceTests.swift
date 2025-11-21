import Testing
import Foundation
internal import UIKit
@testable import Core

@Suite("ImageStorageService Tests")
struct ImageStorageServiceTests {
    let service = ImageStorageService()

    @Test("Save and load image successfully")
    func saveAndLoadImage() async throws {
        // Create a test image
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.red.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        guard let imageData = testImage.jpegData(compressionQuality: 0.9) else {
            Issue.record("Failed to create image data")
            return
        }

        let testID = UUID()

        // Save the image
        let savedPath = try await service.saveImage(imageData, withID: testID)
        #expect(!savedPath.isEmpty)

        // Load the image
        let loadedImage = try await service.loadImage(from: savedPath)
        #expect(loadedImage.size.width > 0)
        #expect(loadedImage.size.height > 0)

        // Clean up
        try? await service.deleteImage(at: savedPath)
    }

    @Test("Generate thumbnail successfully")
    func generateThumbnail() async throws {
        let size = CGSize(width: 1000, height: 1000)
        UIGraphicsBeginImageContext(size)
        UIColor.blue.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        guard let imageData = testImage.jpegData(compressionQuality: 0.9) else {
            Issue.record("Failed to create image data")
            return
        }

        let testID = UUID()

        // Generate thumbnail
        let thumbnailPath = try await service.generateThumbnail(from: imageData, withID: testID)
        #expect(!thumbnailPath.isEmpty)

        // Load thumbnail
        let thumbnail = try await service.loadImage(from: thumbnailPath)
        #expect(thumbnail.size.width <= 300)
        #expect(thumbnail.size.height <= 300)

        // Clean up
        try? await service.deleteImage(at: thumbnailPath)
    }

    @Test("Delete image successfully")
    func deleteImage() async throws {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        UIColor.green.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let testImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        guard let imageData = testImage.jpegData(compressionQuality: 0.9) else {
            Issue.record("Failed to create image data")
            return
        }

        let testID = UUID()

        // Save and delete
        let savedPath = try await service.saveImage(imageData, withID: testID)
        try await service.deleteImage(at: savedPath)

        // Verify deletion
        await #expect(throws: StorageError.self) {
            _ = try await service.loadImage(from: savedPath)
        }
    }
}
