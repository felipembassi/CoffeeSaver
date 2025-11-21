import Foundation
import UIKit

public enum StorageError: Error, LocalizedError {
    case fileNotFound
    case saveFailed
    case deleteFailed
    case invalidImageData
    case thumbnailGenerationFailed

    public var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "The requested file was not found"
        case .saveFailed:
            return "Failed to save the image"
        case .deleteFailed:
            return "Failed to delete the image"
        case .invalidImageData:
            return "The image data is invalid"
        case .thumbnailGenerationFailed:
            return "Failed to generate thumbnail"
        }
    }
}

public actor ImageStorageService: ImageStorageServiceProtocol {
    private let imagesDirectory: URL
    private let thumbnailsDirectory: URL

    public init(fileManager: FileManager = .default) {
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.imagesDirectory = documentsDirectory.appendingPathComponent("CoffeeImages", isDirectory: true)
        self.thumbnailsDirectory = documentsDirectory.appendingPathComponent("Thumbnails", isDirectory: true)

        Self.createDirectoriesIfNeeded(imagesDirectory: imagesDirectory, thumbnailsDirectory: thumbnailsDirectory, fileManager: fileManager)
    }

    private static func createDirectoriesIfNeeded(imagesDirectory: URL, thumbnailsDirectory: URL, fileManager: FileManager) {
        do {
            try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        } catch {
        }

        do {
            try fileManager.createDirectory(at: thumbnailsDirectory, withIntermediateDirectories: true)
        } catch {
        }
    }

    public func saveImage(_ data: Data, withID id: UUID) async throws -> String {
        let filename = "\(id.uuidString).jpg"
        let fileURL = imagesDirectory.appendingPathComponent(filename)

        guard let image = UIImage(data: data),
              let compressedData = image.jpegData(compressionQuality: 0.8) else {
            throw StorageError.invalidImageData
        }

        do {
            try compressedData.write(to: fileURL)
            let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
            // Store only filename, not absolute path
            return filename
        } catch {
            throw StorageError.saveFailed
        }
    }

    public func loadImage(from path: String) async throws -> UIImage {
        // If path is just a filename, construct full path
        let fileURL: URL
        if path.contains("/") {
            // Absolute path (for backward compatibility with old data)
            fileURL = URL(fileURLWithPath: path)
        } else {
            // Relative path (filename) - determine if it's a thumbnail or regular image
            if path.hasSuffix("_thumb.jpg") {
                fileURL = thumbnailsDirectory.appendingPathComponent(path)
            } else {
                fileURL = imagesDirectory.appendingPathComponent(path)
            }
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw StorageError.fileNotFound
        }

        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            throw StorageError.invalidImageData
        }
        return image
    }

    public func deleteImage(at path: String) async throws {
        // If path is just a filename, construct full path
        let fileURL: URL
        if path.contains("/") {
            // Absolute path (for backward compatibility)
            fileURL = URL(fileURLWithPath: path)
        } else {
            // Relative path (filename)
            if path.hasSuffix("_thumb.jpg") {
                fileURL = thumbnailsDirectory.appendingPathComponent(path)
            } else {
                fileURL = imagesDirectory.appendingPathComponent(path)
            }
        }

        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw StorageError.fileNotFound
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            throw StorageError.deleteFailed
        }
    }

    public func generateThumbnail(from data: Data, withID id: UUID) async throws -> String {

        guard let image = UIImage(data: data) else {
            throw StorageError.invalidImageData
        }

        let targetSize = CGSize(width: 300, height: 300)
        let thumbnail = image.preparingThumbnail(of: targetSize) ?? image

        guard let thumbnailData = thumbnail.jpegData(compressionQuality: 0.7) else {
            throw StorageError.thumbnailGenerationFailed
        }

        let filename = "\(id.uuidString)_thumb.jpg"
        let fileURL = thumbnailsDirectory.appendingPathComponent(filename)

        do {
            try thumbnailData.write(to: fileURL)
            let fileExists = FileManager.default.fileExists(atPath: fileURL.path)
            // Store only filename, not absolute path
            return filename
        } catch {
            throw StorageError.saveFailed
        }
    }
}
