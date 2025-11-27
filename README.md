# CoffeeSaver

A SwiftUI iOS app that lets you discover and save random coffee images. Built with modern Swift concurrency, clean architecture, and comprehensive test coverage.

## Features

- 🎲 **Discover**: Browse random coffee images with swipe gestures
- ❤️ **Save**: Keep your favorite coffee images locally
- 📱 **Grid View**: View all saved coffees in an organized grid
- 🗑️ **Delete**: Remove individual saved images
- ✨ **Modern UI**: SwiftUI with smooth animations and gestures

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd CoffeeSaver
```

2. Open the project:
```bash
open CoffeeSaver.xcodeproj
```

3. Build and run:
   - Select a simulator or device
   - Press `Cmd + R` to build and run

## Running Tests

### Unit Tests
```bash
xcodebuild test -scheme CoffeeSaver -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:CoffeeSaverTests
```

### UI Tests
```bash
xcodebuild test -scheme CoffeeSaver -destination 'platform=iOS Simulator,name=iPhone 16 Pro' -only-testing:CoffeeSaverUITests
```

### All Tests
```bash
xcodebuild test -scheme CoffeeSaver -destination 'platform=iOS Simulator,name=iPhone 16 Pro'
```

## Project Structure

```
CoffeeSaver/
├── CoffeeSaverApp/          # Main app target
│   ├── App/                 # App entry point and dependency injection
│   ├── Coordinators/        # App-level coordinator
│   └── Resources/           # Assets and configuration
├── Packages/                # Swift Package modules
│   ├── Core/               # Core business logic and services
│   │   ├── Models/         # Data models (CoffeeImage)
│   │   ├── Networking/     # Network services and reachability
│   │   ├── Persistence/    # Storage services
│   │   └── DependencyInjection/ # Has<Property> protocols
│   ├── Features/           # Feature modules
│   │   ├── CoffeeDiscovery/    # Discovery feature with Coordinator
│   │   └── SavedCoffees/       # Saved coffees feature with Coordinator
│   └── CommonUI/           # Shared UI components and design system
│       ├── Components/     # Reusable views (SwipeableCardView, etc.)
│       ├── DesignSystem/   # Colors, Typography, Spacing, Dimensions
│       └── Routing/        # Router and Coordinator protocols
└── Tests/
    ├── CoffeeSaverTests/   # Unit tests (38 tests)
    └── CoffeeSaverUITests/ # UI tests
```

## Architecture

- **MVVM + Coordinator**: Model-View-ViewModel with Feature Coordinators
- **SwiftData**: For persistent storage
- **Async/Await**: Modern Swift concurrency
- **Actor**: Thread-safe services (NetworkReachability)
- **Has<Property> DI**: Compositional dependency injection pattern
- **Modular**: Swift Package-based architecture

### Feature Coordinators

Each feature has a Coordinator that:
- Owns the ViewModel lifecycle via `@State`
- Receives only the dependencies the feature needs
- Handles feature-level navigation
- Creates and configures the View

### Dependency Injection

The project uses the **Has<Property> pattern** for clean, compositional dependency injection:

- `HasNetworkService` - Protocol for network service access
- `HasStorageService` - Protocol for storage service access
- `HasReachability` - Protocol for network reachability monitoring
- `AppDependencies` - Composition of all Has protocols
- `ServiceContainer` - Concrete implementation with environment-aware service selection

Benefits: Simple, type-safe, testable, and synchronous dependency access.

## Technologies

- **SwiftUI**: Declarative UI framework with `.sensoryFeedback` for haptics
- **SwiftData**: Apple's modern persistence framework
- **Swift Concurrency**: async/await, Actors, Tasks with cancellation support
- **Network Framework**: NWPathMonitor for reachability monitoring
- **URLSession**: Networking with protocol-based abstraction
- **Swift Testing**: Modern testing framework with 38 unit tests
- **@Observable**: Modern observation for ViewModels (iOS 17+)

## API

The app uses the [Coffee API](https://coffee.alexflipnote.dev/) to fetch random coffee images.

## Testing Strategy

- **Unit Tests**: Test view models, services, and business logic with mocks
- **UI Tests**: End-to-end testing of critical user paths
- **Mocks**: All network calls are mocked in tests for reliability and speed
