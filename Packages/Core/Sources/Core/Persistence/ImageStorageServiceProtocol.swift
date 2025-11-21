import Foundation
import UIKit

public protocol ImageStorageServiceProtocol: Sendable {
    func saveImage(_ data: Data, withID id: UUID) async throws -> String
    func loadImage(from path: String) async throws -> UIImage
    func deleteImage(at path: String) async throws
    func generateThumbnail(from data: Data, withID id: UUID) async throws -> String
}
