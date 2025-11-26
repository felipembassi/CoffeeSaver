import Foundation
internal import UIKit
@testable import Core

actor MockImageStorageService: ImageStorageServiceProtocol {
    var shouldFailSave = false
    var shouldFailLoad = false
    var shouldFailDelete = false
    var shouldFailThumbnail = false

    var saveCallCount = 0
    var loadCallCount = 0
    var deleteCallCount = 0
    var thumbnailCallCount = 0

    var savedImages: [UUID: String] = [:]
    var savedThumbnails: [UUID: String] = [:]

    func saveImage(_ data: Data, withID id: UUID) async throws -> String {
        saveCallCount += 1

        if shouldFailSave {
            throw StorageError.saveFailed(underlyingError: NSError(domain: "MockError", code: -1))
        }

        let path = "/fake/path/\(id).jpg"
        savedImages[id] = path
        return path
    }

    func loadImage(from path: String) async throws -> UIImage {
        loadCallCount += 1

        if shouldFailLoad {
            throw StorageError.fileNotFound(path: path)
        }

        return createTestImage(size: CGSize(width: 10, height: 10), color: .red)
    }

    func deleteImage(at path: String) async throws {
        deleteCallCount += 1

        if shouldFailDelete {
            throw StorageError.deleteFailed(underlyingError: NSError(domain: "MockError", code: -1))
        }

        // Remove from mock storage
        savedImages = savedImages.filter { $0.value != path }
        savedThumbnails = savedThumbnails.filter { $0.value != path }
    }

    func generateThumbnail(from data: Data, withID id: UUID) async throws -> String {
        thumbnailCallCount += 1

        if shouldFailThumbnail {
            throw StorageError.thumbnailGenerationFailed
        }

        let path = "/fake/path/\(id)_thumb.jpg"
        savedThumbnails[id] = path
        return path
    }

    func reset() {
        shouldFailSave = false
        shouldFailLoad = false
        shouldFailDelete = false
        shouldFailThumbnail = false
        saveCallCount = 0
        loadCallCount = 0
        deleteCallCount = 0
        thumbnailCallCount = 0
        savedImages = [:]
        savedThumbnails = [:]
    }

    // Setters for test configuration
    func setShouldFailSave(_ value: Bool) {
        shouldFailSave = value
    }

    func setShouldFailLoad(_ value: Bool) {
        shouldFailLoad = value
    }

    func setShouldFailDelete(_ value: Bool) {
        shouldFailDelete = value
    }

    func setShouldFailThumbnail(_ value: Bool) {
        shouldFailThumbnail = value
    }

    // MARK: - Private Helpers

    private func createTestImage(size: CGSize, color: UIColor) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0

        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
