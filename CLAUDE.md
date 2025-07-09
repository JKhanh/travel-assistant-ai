# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-enabled travel assistant application that helps users plan and manage their trips through intelligent checklists, cultural briefings, and payment guidance. The app targets leisure travelers aged 18-55 and provides comprehensive travel assistance from pre-trip planning to on-trip support.

### Core Features

- **Itinerary Management**: Parse booking emails or manual entry of trip details
- **AI-Powered Packing Advisor**: Generate context-aware packing lists based on destination, climate, and activities
- **Smart Travel Checklist**: Dynamic checklist with manual and voice-controlled item tracking
- **Cultural & Legal Briefings**: Local etiquette, dos/don'ts, tipping rules, and legal restrictions
- **Payment Guidance**: Recommendations for cash amounts, supported cards, and mobile wallets
- **Offline Mode**: Full checklist access with sync capabilities when reconnected

### Target Platforms

- Primary: iOS 17+ and Android 13+ mobile apps
- Secondary: Progressive Web App (PWA) for desktop
- Note: While Flutter supports additional platforms, the SRS focuses on mobile-first development

## Development Commands

### Essential Commands

- `flutter run` - Run the app in debug mode on connected device/emulator
- `flutter test` - Run all tests (maintain ≥80% coverage per SRS)
- `flutter analyze` - Run static code analysis
- `flutter pub get` - Install dependencies after modifying pubspec.yaml

### Build Commands

- `flutter build apk` - Build Android APK (primary platform)
- `flutter build ios` - Build iOS app (requires macOS with Xcode)
- `flutter build web` - Build PWA variant
- `flutter build appbundle` - Build Android App Bundle for Play Store

### Testing Commands

- `flutter test test/widget_test.dart` - Run specific test file
- `flutter test --coverage` - Run tests with coverage report
- `flutter drive` - Run integration tests

### Performance Testing

- `flutter run --profile` - Run in profile mode for performance analysis
- `flutter analyze --performance-overlay` - Show performance overlay

## Architecture and Structure

### Proposed Architecture (Clean Architecture)

```
/lib
  /core
    /constants      # App constants, API endpoints
    /errors         # Error handling
    /utils          # Helper functions
    /theme          # App theming
  /data
    /datasources    # Remote and local data sources
    /models         # Data models matching SRS schema
    /repositories   # Repository implementations
  /domain
    /entities       # Business entities (User, Trip, ChecklistItem)
    /repositories   # Repository interfaces
    /usecases       # Business logic
  /presentation
    /screens        # UI screens (Home, Checklist, Trip Wizard, Settings)
    /widgets        # Reusable widgets
    /providers      # State management
```

### Data Models (per SRS Section 6)

- **User**: uid, name, email, locale, currency
- **Trip**: trip_id, uid (FK), start_date, end_date, destinations[]
- **ChecklistItem**: item_id, trip_id (FK), label, category, status, last_updated

### State Management

Use Riverpod or Bloc for:

- User authentication state
- Trip and checklist data
- Offline queue management
- AI response caching

## Key Technologies & Dependencies

### Required Packages

```yaml
# Core functionality
dio: ^5.0.0 # HTTP client for API calls
hive: ^2.0.0 # Local storage for offline mode
riverpod: ^2.0.0 # State management
go_router: ^13.0.0 # Navigation

# AI & ML
google_generative_ai: ^0.4.0 # LLM integration
tflite_flutter: ^0.10.0 # On-device ML models

# Travel features
geolocator: ^11.0.0 # Location services
intl: ^0.19.0 # Internationalization
timezone: ^0.9.0 # Timezone handling

# Voice & Accessibility
speech_to_text: ^6.0.0 # Voice commands
flutter_tts: ^4.0.0 # Text-to-speech

# Authentication & Security
firebase_auth: ^5.0.0 # OAuth 2.0/OIDC
flutter_secure_storage: ^9.0.0 # Secure data storage
crypto: ^3.0.0 # Encryption

# Utilities
permission_handler: ^11.0.0 # Permissions
connectivity_plus: ^5.0.0 # Network status
flutter_nfc_kit: ^3.0.0 # NFC scanning (optional)
```

### External APIs (per SRS Section 3.3)

- OpenWeather API - Weather data
- CultureDB - Etiquette information
- Payments Insight API - Card acceptance data
- Custom Travel APIs as needed

## Development Guidelines

### Code Quality Requirements

1. **Minimum 80% unit test coverage** (SRS requirement)
2. Follow Flutter's widget composition pattern
3. Implement proper error handling for offline scenarios
4. Use dependency injection for testability
5. Document all public APIs and complex logic

### AI Integration Guidelines

1. LLM responses must execute in <3s (95th percentile)
2. Implement response caching to minimize API calls
3. Cap at 20 LLM calls/user/day for free tier
4. Provide fallback responses for AI failures
5. Use prompt engineering for consistent checklist generation

### Offline Mode Implementation

1. Queue all user actions when offline
2. Implement conflict resolution for sync
3. Cache essential data (checklists, tips)
4. Show clear offline indicators
5. Test offline scenarios thoroughly

### Performance Requirements

- Screen loads ≤1s on mid-range devices
- Smooth 60fps scrolling for checklists
- Memory usage <200MB typical
- Battery-efficient background sync

## Security & Compliance

### Security Requirements (per SRS Section 7)

1. OAuth 2.0/OIDC authentication
2. AES-256 encryption at rest
3. TLS 1.3 for data in transit
4. Secure storage for sensitive data
5. No hardcoded API keys or secrets

### Privacy Compliance (GDPR, CCPA, PDPA)

1. Implement user consent flows
2. Data deletion functionality
3. Audit logging for data access
4. Anonymize analytics data
5. 12-month data retention policy

### Compliance Checklist

- [ ] OWASP MASVS Level 1 compliance
- [ ] WCAG 2.2 AA accessibility
- [ ] PCI compliance for card scanning (if implemented)
- [ ] Export control checks for restricted items

## Testing Strategy

### Test Types

1. **Unit Tests**: Business logic, data models, utilities
2. **Widget Tests**: UI component behavior
3. **Integration Tests**: API interactions, database operations
4. **E2E Tests**: Critical user journeys
5. **Performance Tests**: Load times, memory usage

### Key Test Scenarios

- Offline mode functionality
- Voice command accuracy (95% target)
- AI response relevance (≥0.8 score)
- Data sync conflict resolution
- Multi-language support

## Deployment & Release

### Pre-release Checklist

1. Run full test suite with coverage report
2. Verify all external API integrations
3. Security audit (OWASP MASVS)
4. Performance profiling on target devices
5. Accessibility testing (WCAG 2.2 AA)

### Release Process

1. Version bump in pubspec.yaml
2. Generate release notes from tickets
3. Build and sign release artifacts
4. Deploy to app stores (iOS, Android)
5. Update PWA deployment

## Monitoring & Analytics

### Key Metrics to Track

- User satisfaction score (SUS ≥80 target)
- AI response accuracy
- Offline usage patterns
- Feature adoption rates
- Performance metrics (load times, crashes)

### Error Tracking

- Implement Sentry or similar for crash reporting
- Track AI failures and fallback usage
- Monitor API response times
- Log offline sync conflicts

## Notes for Developers

1. The project is currently at boilerplate stage - implement core architecture first
2. Prioritize MVP features (F-01 to F-07 in SRS)
3. Design for offline-first experience
4. Consider localization early (multiple currencies, languages)
5. Plan for iterative AI model improvements
6. Implement analytics to validate feature usage
