import SwiftUI
import SwiftData
import CommonUI
import Core

public struct SavedCoffeesView: View {
    @Query(sort: \CoffeeImage.dateSaved, order: .reverse) private var savedCoffees: [CoffeeImage]
    @State var viewModel: SavedCoffeesViewModel
    let router: Router

    @State private var imageToDelete: CoffeeImage?
    @State private var showDeleteAlert = false

    public init(viewModel: SavedCoffeesViewModel, router: Router) {
        self.viewModel = viewModel
        self.router = router
    }

    public var body: some View {
        ZStack {
            if savedCoffees.isEmpty {
                emptyState
            } else {
                coffeeGrid
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle(Strings.Navigation.saved)
        .navigationBarTitleDisplayMode(.large)
        .alert(Strings.Alert.Delete.title, isPresented: $showDeleteAlert, presenting: imageToDelete) { coffee in
            Button(Strings.Alert.Delete.cancel, role: .cancel) {}
            Button(Strings.Alert.Delete.confirm, role: .destructive) {
                Task {
                    try? await viewModel.deleteCoffee(coffee)
                }
            }
        } message: { _ in
            Text(Strings.Alert.Delete.message)
        }
    }

    private var emptyState: some View {
        VStack(spacing: Spacing.large) {
            Image(systemName: "heart.slash.fill")
                .font(Typography.emojiLarge)
                .foregroundStyle(Colors.placeholderIcon.opacity(0.5))

            Text(Strings.Saved.Empty.title)
                .font(Typography.title2)
                .fontWeight(.semibold)

            Text(Strings.Saved.Empty.message)
                .font(Typography.body)
                .foregroundStyle(Colors.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xxxLarge)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("saved-empty-state")
    }

    private var coffeeGrid: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: Spacing.gridSpacing),
                GridItem(.flexible(), spacing: Spacing.gridSpacing)
            ], spacing: Spacing.gridSpacing) {
                ForEach(savedCoffees) { coffee in
                    CoffeeThumbnailView(
                        coffee: coffee,
                        viewModel: viewModel,
                        onDelete: {
                            imageToDelete = coffee
                            showDeleteAlert = true
                        }
                    )
                }
            }
            .padding(Spacing.medium)
        }
        .accessibilityIdentifier("saved-grid")
    }
}

struct CoffeeThumbnailView: View {
    let coffee: CoffeeImage
    let viewModel: SavedCoffeesViewModel
    let onDelete: () -> Void

    @State private var loadedImage: UIImage?
    @State private var isLoading = true

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topTrailing) {
                Group {
                    if let image = loadedImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                    } else if isLoading {
                        Rectangle()
                            .fill(Colors.placeholder)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .overlay {
                                ProgressView()
                            }
                    } else {
                        Rectangle()
                            .fill(Colors.placeholder)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .overlay {
                                Image(systemName: "photo")
                                    .foregroundStyle(Colors.placeholderIcon)
                            }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Spacing.thumbnailCornerRadius))

                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(Typography.title2)
                        .foregroundStyle(.white)
                        .background(Circle().fill(Colors.shadow(opacity: 0.5)))
                        .padding(Spacing.xSmall)
                }
                .accessibilityIdentifier("delete-button-\(coffee.id)")
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .task {
            await loadThumbnail()
        }
    }

    private func loadThumbnail() async {
        let imagePath = coffee.thumbnailPath ?? coffee.localPath

        do {
            let image = try await viewModel.loadImage(from: imagePath)
            await MainActor.run {
                loadedImage = image
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
            }
        }
    }
}
