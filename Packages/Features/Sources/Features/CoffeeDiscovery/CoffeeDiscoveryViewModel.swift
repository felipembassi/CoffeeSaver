import Foundation
import SwiftUI
import SwiftData
import Core

// MARK: - Constants

private enum Constants {
    static let maxImageDimension: CGFloat = 1200
    static let jpegCompressionQuality: CGFloat = 0.9
}

@MainActor
@Observable
public final class CoffeeDiscoveryViewModel {
    private let coffeeAPIClient: CoffeeAPIClientProtocol
    private let storageService: ImageStorageServiceProtocol
    private let modelContext: ModelContext

    public enum LoadingState: Equatable {
        case idle
        case loading
        case loaded(UIImage)
        case error(String)

        public static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading):
                return true
            case (.loaded(let lhsImage), .loaded(let rhsImage)):
                return lhsImage === rhsImage
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }

    public private(set) var loadingState: LoadingState = .idle
    public private(set) var currentCoffeeURL: String?
    public private(set) var isSaving = false

    public init(
        coffeeAPIClient: CoffeeAPIClientProtocol,
        storageService: ImageStorageServiceProtocol,
        modelContext: ModelContext
    ) {
        self.coffeeAPIClient = coffeeAPIClient
        self.storageService = storageService
        self.modelContext = modelContext
    }

    public func loadRandomCoffee() async {
        loadingState = .loading

        do {
            let response = try await coffeeAPIClient.fetchRandomCoffee()

            // Check for cancellation after network call
            try Task.checkCancellation()

            currentCoffeeURL = response.file

            guard let imageURL = response.imageURL else {
                throw NetworkError.invalidURL
            }

            let imageData = try await coffeeAPIClient.downloadImage(from: imageURL)

            // Check for cancellation after image download
            try Task.checkCancellation()

            // Downsample large images to avoid memory issues
            let targetSize = CGSize(width: Constants.maxImageDimension, height: Constants.maxImageDimension)
            guard let image = downsampleImage(data: imageData, to: targetSize) else {
                throw NetworkError.imageConversionFailed
            }

            loadingState = .loaded(image)
        } catch is CancellationError {
            // Task was cancelled, don't update state
            return
        } catch {
            loadingState = .error(error.localizedDescription)
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
              let imageData = image.jpegData(compressionQuality: Constants.jpegCompressionQuality) else {
            return
        }

        isSaving = true
        defer { isSaving = false }

        do {
            let coffeeID = UUID()

            // Save full image
            let imagePath = try await storageService.saveImage(imageData, withID: coffeeID)

            // Check for cancellation after file operation
            try Task.checkCancellation()

            // Generate thumbnail
            let thumbnailPath = try await storageService.generateThumbnail(from: imageData, withID: coffeeID)

            // Check for cancellation after thumbnail generation
            try Task.checkCancellation()

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
        } catch is CancellationError {
            // Task was cancelled, don't update state
            return
        } catch {
            loadingState = .error(error.localizedDescription)
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
        if case .error(let message) = loadingState {
            return message
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
