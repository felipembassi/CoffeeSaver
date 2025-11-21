import Foundation
import SwiftUI
import SwiftData
import Core

@MainActor
@Observable
public final class CoffeeDiscoveryViewModel {
    private let apiService: CoffeeAPIServiceProtocol
    private let storageService: ImageStorageServiceProtocol
    private let modelContext: ModelContext

    public enum LoadingState {
        case idle
        case loading
        case loaded(UIImage)
        case error(Error)
    }

    public private(set) var loadingState: LoadingState = .idle
    public private(set) var currentCoffeeURL: String?
    public private(set) var isSaving = false

    public init(
        apiService: CoffeeAPIServiceProtocol,
        storageService: ImageStorageServiceProtocol,
        modelContext: ModelContext
    ) {
        self.apiService = apiService
        self.storageService = storageService
        self.modelContext = modelContext
    }

    public func loadRandomCoffee() async {
        loadingState = .loading

        do {
            let response = try await apiService.fetchRandomCoffee()
            currentCoffeeURL = response.file

            guard let imageURL = URL(string: response.file) else {
                throw NetworkError.invalidURL
            }

            let imageData = try await apiService.downloadImage(from: imageURL)

            // Downsample large images to avoid memory issues
            guard let image = downsampleImage(data: imageData, to: CGSize(width: 1200, height: 1200)) else {
                throw NetworkError.imageConversionFailed
            }

            loadingState = .loaded(image)
        } catch {
            loadingState = .error(error)
        }
    }

    private func downsampleImage(data: Data, to targetSize: CGSize) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }

        let maxDimensionInPixels = max(targetSize.width, targetSize.height)
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }

    public func saveCoffee() async {
        guard case .loaded(let image) = loadingState,
              let coffeeURL = currentCoffeeURL,
              let imageData = image.jpegData(compressionQuality: 0.9) else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let coffeeID = UUID()

            // Save full image
            let imagePath = try await storageService.saveImage(imageData, withID: coffeeID)

            // Generate thumbnail
            let thumbnailPath = try await storageService.generateThumbnail(from: imageData, withID: coffeeID)

            // Save to SwiftData
            let coffeeImage = CoffeeImage(
                id: coffeeID,
                remoteURL: coffeeURL,
                localPath: imagePath,
                thumbnailPath: thumbnailPath
            )

            modelContext.insert(coffeeImage)
            try modelContext.save()

            // Load next coffee after successful save
            await loadRandomCoffee()
        } catch {
            loadingState = .error(error)
        }
    }

    public func skipCoffee() async {
        await loadRandomCoffee()
    }

    public var currentImage: UIImage? {
        if case .loaded(let image) = loadingState {
            return image
        }
        return nil
    }

    public var errorMessage: String? {
        if case .error(let error) = loadingState {
            return error.localizedDescription
        }
        return nil
    }

    public var isLoading: Bool {
        if case .loading = loadingState {
            return true
        }
        return false
    }
}
