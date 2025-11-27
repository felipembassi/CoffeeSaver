import SwiftUI

public enum CardStyle {
    case standard
    case tinder
}

public enum SwipeDirection {
    case left
    case right
}

public struct SwipeableCardView: View {
    private var image: UIImage?
    private var style: CardStyle
    private var onSave: () -> Void
    private var onSkip: () -> Void
    private var enableHaptics: Bool

    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var isAnimating = false
    @State private var pendingAction: SwipeDirection?
    @State private var swipeCompleted = false

    private let swipeThreshold: CGFloat = Spacing.swipeThreshold

    public init(
        image: UIImage? = nil,
        style: CardStyle = .tinder,
        onSave: @escaping () -> Void = {},
        onSkip: @escaping () -> Void = {},
        enableHaptics: Bool = true
    ) {
        self.image = image
        self.style = style
        self.onSave = onSave
        self.onSkip = onSkip
        self.enableHaptics = enableHaptics
    }

    public var body: some View {
        GeometryReader { geometry in
            ZStack {
                cardContent(size: geometry.size)
                    .overlay(alignment: .center) {
                        if style == .tinder {
                            swipeOverlay
                        }
                    }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .offset(x: offset.width, y: offset.height)
            .rotationEffect(.degrees(rotation))
            .gesture(dragGesture)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: offset)
            .onChange(of: offset) { _, newValue in
                handleAnimationCompletion(newValue)
            }
            .sensoryFeedback(.impact(weight: .medium), trigger: swipeCompleted) { _, newValue in
                enableHaptics && newValue
            }
        }
        .aspectRatio(5/7, contentMode: .fit)
    }

    private func handleAnimationCompletion(_ newOffset: CGSize) {
        // Check if animation completed (card moved off-screen)
        guard let direction = pendingAction,
              abs(newOffset.width) >= Dimensions.swipeOffscreenDistance else {
            return
        }

        // Execute the action
        if direction == .right {
            onSave()
        } else {
            onSkip()
        }

        // Reset state
        pendingAction = nil
        offset = .zero
        rotation = 0
        isAnimating = false
    }

    private func cardContent(size: CGSize) -> some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: style == .tinder ? Spacing.cardCornerRadius : Spacing.standardCornerRadius))
                    .shadow(color: Colors.shadow(), radius: Dimensions.shadowRadius, x: Dimensions.shadowX, y: Dimensions.shadowY)
            } else {
                RoundedRectangle(cornerRadius: style == .tinder ? Spacing.cardCornerRadius : Spacing.standardCornerRadius)
                    .fill(Colors.placeholder)
                    .frame(width: size.width, height: size.height)
                    .overlay {
                        ProgressView()
                    }
                    .shadow(color: Colors.shadow(), radius: Dimensions.shadowRadius, x: Dimensions.shadowX, y: Dimensions.shadowY)
            }
        }
    }

    @ViewBuilder
    private var swipeOverlay: some View {
        if abs(offset.width) > swipeThreshold / 2 {
            ZStack {
                if offset.width > 0 {
                    // Save overlay (right swipe)
                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                        .fill(Colors.likeOverlay())
                    Image(systemName: "heart.fill")
                        .font(Typography.iconLargeFont)
                        .foregroundStyle(Colors.like)
                        .shadow(radius: Dimensions.shadowRadius)
                } else {
                    // Skip overlay (left swipe)
                    RoundedRectangle(cornerRadius: Spacing.cardCornerRadius)
                        .fill(Colors.dislikeOverlay())
                    Image(systemName: "xmark")
                        .font(Typography.iconLargeFont)
                        .foregroundStyle(Colors.dislike)
                        .shadow(radius: Dimensions.shadowRadius)
                }
            }
            .transition(.opacity)
        }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                guard style == .tinder, !isAnimating else { return }
                offset = value.translation
                rotation = Double(value.translation.width / Dimensions.rotationDivider)
            }
            .onEnded { value in
                guard style == .tinder else { return }
                handleSwipeEnd(translation: value.translation)
            }
    }

    private func handleSwipeEnd(translation: CGSize) {
        guard !isAnimating else { return }

        if abs(translation.width) > swipeThreshold {
            isAnimating = true

            if translation.width > 0 {
                completeSwipe(.right)
            } else {
                completeSwipe(.left)
            }
        } else {
            // Return to center
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                offset = .zero
                rotation = 0
            }
        }
    }

    private func completeSwipe(_ direction: SwipeDirection) {
        let targetX: CGFloat = direction == .right ? Dimensions.swipeOffscreenDistance : -Dimensions.swipeOffscreenDistance

        // Store the pending action to be executed when animation completes
        pendingAction = direction

        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            offset = CGSize(width: targetX, height: 0)
            rotation = direction == .right ? Dimensions.maxRotation : -Dimensions.maxRotation
        }

        // Trigger haptic feedback via SwiftUI's sensoryFeedback modifier
        swipeCompleted.toggle()
    }
}

// MARK: - Builder Pattern Extensions

public extension SwipeableCardView {
    func cardImage(_ image: UIImage?) -> Self {
        var copy = self
        copy.image = image
        return copy
    }

    func cardStyle(_ style: CardStyle) -> Self {
        var copy = self
        copy.style = style
        return copy
    }

    func onSave(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onSave = action
        return copy
    }

    func onSkip(_ action: @escaping () -> Void) -> Self {
        var copy = self
        copy.onSkip = action
        return copy
    }

    func enableHaptics(_ enabled: Bool) -> Self {
        var copy = self
        copy.enableHaptics = enabled
        return copy
    }
}
