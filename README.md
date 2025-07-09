# Travel Assistant AI

An AI-enabled travel assistant application that helps users plan and manage their trips through intelligent checklists, cultural briefings, and payment guidance.

## Features

- **Itinerary Management**: Parse booking emails or manual entry of trip details
- **AI-Powered Packing Advisor**: Generate context-aware packing lists based on destination, climate, and activities
- **Smart Travel Checklist**: Dynamic checklist with manual and voice-controlled item tracking
- **Cultural & Legal Briefings**: Local etiquette, dos/don'ts, tipping rules, and legal restrictions
- **Payment Guidance**: Recommendations for cash amounts, supported cards, and mobile wallets
- **Offline Mode**: Full checklist access with sync capabilities when reconnected

## Target Platforms

- Primary: iOS 17+ and Android 13+ mobile apps
- Secondary: Progressive Web App (PWA) for desktop

## Development

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK
- Android Studio / Xcode for mobile development

### Getting Started

1. Clone the repository:

```bash
git clone git@github.com:JKhanh/travel-assistant-ai.git
cd travel-assistant-ai
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app:

```bash
flutter run
```

### Development Commands

- `flutter run` - Run the app in debug mode
- `flutter test` - Run all tests
- `flutter analyze` - Run static code analysis
- `flutter build apk` - Build Android APK
- `flutter build web` - Build web version

### Monorepo Management

This project uses Melos for monorepo management:

```bash
# Install melos globally
dart pub global activate melos

# Run commands across all packages
melos run analyze
melos run format
melos run test
```

## Architecture

The project follows Clean Architecture principles with:

- **Domain Layer**: Business logic and entities
- **Data Layer**: Repository implementations and data sources
- **Presentation Layer**: UI components and state management

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and ensure code quality
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Repository

- GitHub: [https://github.com/JKhanh/travel-assistant-ai](https://github.com/JKhanh/travel-assistant-ai)
- Issues: [https://github.com/JKhanh/travel-assistant-ai/issues](https://github.com/JKhanh/travel-assistant-ai/issues)
