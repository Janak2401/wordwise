# WordWise 📚✨

**WordWise** is an offline-first mobile word puzzle game built with Flutter, inspired by Wordle and designed explicitly to help players expand and master vocabulary through engaging gameplay.

---

## 🌟 Key Features

- **Dynamic Word Lengths & Guess Limits**:
  - 5 letters $\rightarrow$ 6 guesses
  - 6 letters $\rightarrow$ 7 guesses
  - 7 letters $\rightarrow$ 8 guesses
- **Vocabulary-First Gameplay**:
  - Real-time definition clues during the game.
  - Comprehensive post-game review with phonetics, parts of speech, examples, and synonyms.
  - Native Text-to-Speech (TTS) audio pronunciation.
- **Personal Word Bank**:
  - Bookmark challenging words to a local study deck.
  - Full-text search across saved words and definitions.
- **Stats & Progress Tracking**:
  - Win percentage, current streak, max streak, and interactive guess distribution histograms.
- **Minimal Ink Design**:
  - Distraction-free, flat dark charcoal aesthetic (`#121213`) with smooth 3D tile animations and custom tactile keyboard.
- **100% Offline-First**:
  - Powered by local SQLite dictionary database and Hive key-value storage. No cloud dependencies or logins required.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart)
- **State Management**: [Riverpod 2.x](https://riverpod.dev) (`flutter_riverpod`, `StateNotifier`)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Storage**: 
  - [Hive](https://pub.dev/packages/hive_flutter) (Preferences, streaks, game state)
  - [SQLite](https://pub.dev/packages/sqflite) (`sqflite` for curated vocabulary & word bank)
- **Audio & TTS**: [flutter_tts](https://pub.dev/packages/flutter_tts)
- **Typography & Styling**: Google Fonts (`Inter`)

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/       # App colors, typography, dimensions, game rules
│   ├── router/          # GoRouter configuration
│   ├── theme/           # Minimal Ink ThemeData
│   └── utils/           # Haptics, share formatting, date helpers
├── data/
│   ├── datasources/     # SQLite database & Hive stores
│   ├── models/          # Word, BookmarkedWord, GuessResult models
│   └── repositories/    # Dictionary repository
├── features/
│   ├── game/            # Grid, keyboard, tiles, post-game modal, game logic
│   ├── word_bank/       # Saved vocabulary deck & search
│   ├── stats/           # Streak & guess distribution charts
│   ├── settings/        # Audio/haptic toggles & preferences
│   ├── onboarding/      # First-launch walkthrough
│   └── how_to_play/     # Rules & tile color guides
└── main.dart            # Application entry point & service bootstrap
```

---

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.19.0+)
- Android Studio / Xcode / VS Code
- Android SDK (API 21+) or iOS (12+)

### Installation & Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Janak2401/wordwise.git
   cd wordwise
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on connected device / emulator:
   ```bash
   flutter run
   ```

4. Build Release APK:
   ```bash
   flutter build apk --release
   ```
   *Output location: `build/app/outputs/flutter-apk/app-release.apk`*

---

## 🧪 Testing

Run all unit and widget tests:
```bash
flutter test
```

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
