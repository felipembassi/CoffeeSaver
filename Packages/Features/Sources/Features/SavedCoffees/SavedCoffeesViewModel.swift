import Foundation
import SwiftUI
import SwiftData
import Core

@MainActor
@Observable
public final class SavedCoffeesViewModel {
    private let storageService: ImageStorageServiceProtocol
    private let modelContext: ModelContext

    public init(
        storageService: ImageStorageServiceProtocol,
        modelContext: ModelContext
    ) {
        self.storageService = storageService
        self.modelContext = modelContext
    }

    public func deleteCoffee(_ coffee: CoffeeImage) async throws {
        // Delete image files
        try await storageService.deleteImage(at: coffee.localPath)

        if let thumbnailPath = coffee.thumbnailPath {
            try? await storageService.deleteImage(at: thumbnailPath)
        }

        // Delete from SwiftData
        modelContext.delete(coffee)
        try modelContext.save()
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
