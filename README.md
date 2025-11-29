# Sky Shop

A modern Flutter e-commerce application with live shopping events, product catalog, cart management, and user authentication.

## Flutter Version

- **Flutter SDK**: 3.24.0 (stable channel)
- **Dart SDK**: ^3.9.2

## Architecture

This project follows a **Riverpod-based Layered Architecture** with clear separation of concerns:

### Architecture Layers

1. **Models Layer** (`lib/models/`)
   - Data models (User, Product, Cart, Order, Category, etc.)
   - JSON serialization support

2. **Services Layer** (`lib/services/`)
   - Business logic and API interactions
   - Services: `AuthService`, `CartService`, `ApiService`, `StorageService`, `SocketService`
   - Mock services for development/testing

3. **Providers Layer** (`lib/providers/`)
   - Riverpod providers for state management
   - Dependency injection and reactive state
   - Providers expose services and derived state

4. **Presentation Layer** (`lib/screens/`)
   - UI screens using `ConsumerWidget`/`ConsumerStatefulWidget`
   - Screens consume providers via `ref.watch()` and `ref.read()`

5. **Widgets Layer** (`lib/widgets/`)
   - Reusable UI components
   - Common widgets (TopBar, Footer, OptimizedImage, etc.)
   - Live event widgets

6. **Utils Layer** (`lib/utils/`)
   - Helper functions and constants
   - Lazy loading utilities

### Key Architecture Patterns

- **State Management**: Riverpod for reactive state management
- **Dependency Injection**: Services injected via Riverpod providers
- **Routing**: GoRouter for declarative navigation with lazy loading
- **Code Splitting**: Deferred imports for optimized bundle sizes
- **Service-Oriented Design**: Business logic encapsulated in service classes

## Tools & Dependencies

### Core Dependencies

- **State Management**: `flutter_riverpod: ^3.0.3`
- **Routing**: `go_router: ^17.0.0`
- **Networking**: `dio: ^5.9.0`
- **Local Storage**: `shared_preferences: ^2.3.3`
- **Image Loading**: `cached_network_image: ^3.4.1`
- **SVG Support**: `flutter_svg: ^2.0.10+1`
- **Video Player**: `video_player: ^2.10.1`, `chewie: ^1.13.0`
- **UI Effects**: `shimmer: ^3.0.0`
- **JSON Serialization**: `json_annotation: ^4.9.0`

### Development Dependencies

- **Linting**: `flutter_lints: ^6.0.0`, `riverpod_lint: ^3.0.3`
- **Code Generation**: `build_runner: ^2.7.1`, `json_serializable: ^6.11.2`, `riverpod_generator: ^3.0.3`

## Getting Started

### Prerequisites

- Flutter SDK 3.24.0 or higher
- Dart SDK 3.9.2 or higher

### Installation

R

## Deployment

### Web Deployment to GitHub Pages

The project includes automated deployment to GitHub Pages via GitHub Actions.

#### Automatic Deployment

The app automatically deploys when pushing to `main`, `master`, or `dev` branches. The deployment workflow:

1. Sets up Flutter 3.24.0
2. Installs dependencies
3. Builds the web app in release mode
4. Deploys to GitHub Pages

#### Manual Deployment

To deploy manually:

1. **Build for web**:
```bash
flutter build web --release --base-href "/sky_shop/"
```
   - For user/organization sites (username.github.io), use `--base-href "/"` instead

2. **Deploy to GitHub Pages**:
   - The GitHub Actions workflow will handle the deployment automatically
   - Or manually upload the `build/web` directory to your GitHub Pages repository

#### Deployment Configuration

The deployment workflow is configured in `.github/workflows/deploy-pages.yml`. Key settings:

- **Flutter Version**: 3.24.0 (stable)
- **Base Href**: `/sky_shop/` (adjust for your repository name)
- **Build Output**: `build/web`

### Other Platforms

#### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

#### Desktop
```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
```

## Project Structure

```
lib/
├── app.dart                 # App configuration and routing
├── main.dart                # Entry point
├── config/                  # Configuration files
│   ├── api_config.dart
│   └── theme_config.dart
├── models/                  # Data models
├── providers/               # Riverpod providers
├── screens/                 # UI screens
├── services/                # Business logic services
├── utils/                   # Utilities and helpers
└── widgets/                 # Reusable widgets
    ├── common/
    └── live/
```

## Features

- 🛍️ Product catalog with categories
- 🛒 Shopping cart with persistence
- 🔐 User authentication
- 📺 Live shopping events
- 🔔 Notifications
- 📦 Order management
- 🔍 Product search
- 💳 Checkout process

## Development Notes

- The app uses mock API data for development (see `assets/mock-api-data.json`)
- Services are designed to be easily replaceable with real API implementations
- Code splitting is implemented for optimal web performance
- Critical assets are preloaded on app startup

## License

[Add your license information here]
