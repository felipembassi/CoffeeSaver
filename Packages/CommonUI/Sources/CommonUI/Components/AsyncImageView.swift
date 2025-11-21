import SwiftUI

public struct AsyncImageView: View {
    let url: URL?
    let placeholder: Image?

    public init(url: URL?, placeholder: Image? = nil) {
        self.url = url
        self.placeholder = placeholder
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                if let placeholder = placeholder {
                    placeholder
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.gray)
                        .padding(40)
                }
            @unknown default:
                EmptyView()
            }
        }
    }
}

// MARK: - Builder Pattern Extensions

public extension AsyncImageView {
    func placeholder(_ image: Image) -> Self {
        AsyncImageView(url: url, placeholder: image)
    }
}
