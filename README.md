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
│   └── Resources/           # Assets and configuration
├── Packages/                # Swift Package modules
│   ├── Core/               # Core business logic and services
│   │   ├── Models/         # Data models (CoffeeImage)
│   │   ├── Services/       # API and storage services
│   │   └── Mocks/          # Mock implementations for testing
│   ├── Features/           # Feature modules
│   │   ├── Discovery/      # Coffee discovery feature
│   │   └── SavedCoffees/   # Saved coffees feature
│   └── CommonUI/           # Shared UI components and design system
└── Tests/
    ├── CoffeeSaverTests/   # Unit tests
    └── CoffeeSaverUITests/ # UI tests
```

## Architecture

- **MVVM**: Model-View-ViewModel pattern
- **SwiftData**: For persistent storage
- **Async/Await**: Modern Swift concurrency
- **Actor**: Thread-safe services
- **Has<Property> DI**: Compositional dependency injection pattern
- **Modular**: Swift Package-based architecture

### Dependency Injection

The project uses the **Has<Property> pattern** for clean, compositional dependency injection:

- `HasAPIService` - Protocol for API service access
- `HasStorageService` - Protocol for storage service access
- `AppDependencies` - Composition of all Has protocols
- `ServiceContainer` - Concrete implementation with environment-aware service selection

Benefits: Simple, type-safe, testable, and synchronous dependency access.

## Technologies

- **SwiftUI**: Declarative UI framework
- **SwiftData**: Apple's modern persistence framework
- **Async/Await**: Swift concurrency for asynchronous operations
- **Actor**: Thread-safe concurrent programming
- **URLSession**: Networking
- **XCTest**: Unit and UI testing
- **Swift Testing**: Modern testing framework

## API

The app uses the [Coffee API](https://coffee.alexflipnote.dev/) to fetch random coffee images.

## Testing Strategy

- **Unit Tests**: Test view models, services, and business logic with mocks
- **UI Tests**: End-to-end testing of critical user paths
- **Mocks**: All network calls are mocked in tests for reliability and speed

## License

[Add your license here]

## Author

[Add your name/info here]
