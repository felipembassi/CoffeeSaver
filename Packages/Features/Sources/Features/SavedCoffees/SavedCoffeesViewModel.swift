import Foundation
import SwiftUI
import SwiftData
import Core

@MainActor
@Observable
public final class SavedCoffeesViewModel {
    /// Dependencies required by this ViewModel.
    public typealias Dependencies = HasStorageService

    private let storageService: ImageStorageServiceProtocol
    private let modelContext: ModelContext

    public init(
        dependencies: Dependencies,
        modelContext: ModelContext
    ) {
        self.storageService = dependencies.storageService
        self.modelContext = modelContext
    }

    public func deleteCoffee(_ coffee: CoffeeImage) async throws {
        // Capture paths before deletion from SwiftData
        let localPath = coffee.localPath
        let thumbnailPath = coffee.thumbnailPath

        // Delete from SwiftData first (atomic operation)
        modelContext.delete(coffee)
        try modelContext.save()

        // Clean up files after successful SwiftData deletion
        // File cleanup errors are non-fatal - the record is already deleted
        try? await storageService.deleteImage(at: localPath)

        if let thumbnailPath {
            try? await storageService.deleteImage(at: thumbnailPath)
        }
    }

    public func loadImage(from path: String) async throws -> UIImage {
        try await storageService.loadImage(from: path)
    }

    /// Deletes all saved coffees - useful for testing
    public func deleteAllCoffees() async throws {
        let descriptor = FetchDescriptor<CoffeeImage>()
        let allCoffees = try modelContext.fetch(descriptor)

        for coffee in allCoffees {
            // Delete image files
            try? await storageService.deleteImage(at: coffee.localPath)
            if let thumbnailPath = coffee.thumbnailPath {
                try? await storageService.deleteImage(at: thumbnailPath)
            }

            // Delete from SwiftData
            modelContext.delete(coffee)
        }

        try modelContext.save()
    }
}
