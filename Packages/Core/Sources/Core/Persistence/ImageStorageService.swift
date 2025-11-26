import Foundation
import UIKit

// MARK: - Constants

private enum StorageConstants {
    static let imageCompressionQuality: CGFloat = 0.8
    static let thumbnailCompressionQuality: CGFloat = 0.7
    static let thumbnailSize = CGSize(width: 300, height: 300)
    static let imagesDirectoryName = "CoffeeImages"
    static let thumbnailsDirectoryName = "Thumbnails"
}

// MARK: - Storage Error

public enum StorageError: Error, LocalizedError, Sendable {
    case fileNotFound(path: String)
    case saveFailed(underlyingError: Error)
    case deleteFailed(underlyingError: Error)
    case invalidImageData
    case thumbnailGenerationFailed
    case cancelled

    public var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "The requested file was not found at: \(path)"
        case .saveFailed(let error):
            return "Failed to save the image: \(error.localizedDescription)"
        case .deleteFailed(let error):
            return "Failed to delete the image: \(error.localizedDescription)"
        case .invalidImageData:
            return "The image data is invalid"
        case .thumbnailGenerationFailed:
            return "Failed to generate thumbnail"
        case .cancelled:
            return "The operation was cancelled"
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .fileNotFound:
            return "The file may have been moved or deleted"
        case .saveFailed:
            return "Check available storage space and permissions"
        case .deleteFailed:
            return "Check file permissions"
        case .invalidImageData:
            return "The image format may be unsupported"
        case .thumbnailGenerationFailed:
            return "Try saving the image again"
        case .cancelled:
            return nil
        }
    }
}

/// A service for saving, loading, and managing images on disk.
///
/// `ImageStorageService` is a `Sendable` struct that performs file I/O operations
/// with proper priority handling to avoid priority inversion when called from the main thread.
/// All operations support cancellation via Swift's structured concurrency.
public struct ImageStorageService: ImageStorageServiceProtocol, Sendable {
    private let imagesDirectory: URL
    private let thumbnailsDirectory: URL

    /// Creates a storage service using the app's Documents directory.
    public init(fileManager: FileManager = .default) {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.init(baseDirectory: documentsDirectory, fileManager: fileManager)
    }

    /// Creates a storage service with a custom base directory.
    /// Useful for testing with a temporary directory.
    ///
    /// - Parameters:
    ///   - baseDirectory: The base directory for storing images.
    ///   - fileManager: The file manager to use for directory creation.
    public init(baseDirectory: URL, fileManager: FileManager = .default) {
        self.imagesDirectory = baseDirectory.appendingPathComponent(StorageConstants.imagesDirectoryName, isDirectory: true)
        self.thumbnailsDirectory = baseDirectory.appendingPathComponent(StorageConstants.thumbnailsDirectoryName, isDirectory: true)

        Self.createDirectoriesIfNeeded(imagesDirectory: imagesDirectory, thumbnailsDirectory: thumbnailsDirectory, fileManager: fileManager)
    }

    /// Creates a storage service for testing using a temporary directory.
    /// The directory is automatically cleaned up by the system.
    public static func forTesting() -> ImageStorageService {
        let tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("CoffeeSaverTests-\(UUID().uuidString)", isDirectory: true)
        return ImageStorageService(baseDirectory: tempDirectory)
    }

    private static func createDirectoriesIfNeeded(imagesDirectory: URL, thumbnailsDirectory: URL, fileManager: FileManager) {
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        try? fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
    }

    public func saveImage(_ data: Data, withID id: UUID) async throws -> String {
        let imagesDir = imagesDirectory
        return try await Task(priority: .userInitiated) {
            try Task.checkCancellation()

            let filename = "\(id.uuidString).jpg"
            let fileURL = imagesDir.appendingPathComponent(filename)

            guard let image = UIImage(data: data),
                  let compressedData = image.jpegData(compressionQuality: StorageConstants.imageCompressionQuality) else {
                throw StorageError.invalidImageData
            }

            try Task.checkCancellation()

            do {
                try compressedData.write(to: fileURL)
                return filename
            } catch {
                throw StorageError.saveFailed(underlyingError: error)
            }
        }.value
    }

    public func loadImage(from path: String) async throws -> UIImage {
        let fileURL = resolveFileURL(for: path)
        return try await Task(priority: .userInitiated) {
            try Task.checkCancellation()

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw StorageError.fileNotFound(path: path)
            }

            guard let data = try? Data(contentsOf: fileURL),
                  let image = UIImage(data: data) else {
                throw StorageError.invalidImageData
            }
            return image
        }.value
    }

    public func deleteImage(at path: String) async throws {
        let fileURL = resolveFileURL(for: path)
        try await Task(priority: .userInitiated) {
            try Task.checkCancellation()

            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                throw StorageError.fileNotFound(path: path)
            }

            do {
                try FileManager.default.removeItem(at: fileURL)
            } catch {
                throw StorageError.deleteFailed(underlyingError: error)
            }
        }.value
    }

    public func generateThumbnail(from data: Data, withID id: UUID) async throws -> String {
        let thumbnailsDir = thumbnailsDirectory
        return try await Task(priority: .userInitiated) {
            try Task.checkCancellation()

            guard let image = UIImage(data: data) else {
                throw StorageError.invalidImageData
            }

            let thumbnail = image.preparingThumbnail(of: StorageConstants.thumbnailSize) ?? image

            guard let thumbnailData = thumbnail.jpegData(compressionQuality: StorageConstants.thumbnailCompressionQuality) else {
                throw StorageError.thumbnailGenerationFailed
            }

            try Task.checkCancellation()

            let filename = "\(id.uuidString)_thumb.jpg"
            let fileURL = thumbnailsDir.appendingPathComponent(filename)

            do {
                try thumbnailData.write(to: fileURL)
                return filename
            } catch {
                throw StorageError.saveFailed(underlyingError: error)
            }
        }.value
    }

    // MARK: - Private Helpers

    private func resolveFileURL(for path: String) -> URL {
        if path.contains("/") {
            return URL(fileURLWithPath: path)
        } else if path.hasSuffix("_thumb.jpg") {
            return thumbnailsDirectory.appendingPathComponent(path)
        } else {
            return imagesDirectory.appendingPathComponent(path)
        }
    }
}
