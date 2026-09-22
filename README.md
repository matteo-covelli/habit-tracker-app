# Habit Tracker App 🎯

A sleek, offline-first mobile application designed to help users build and maintain daily habits. Built with **Flutter**, **Riverpod**, and clean feature-first architecture principles.

---

## 📱 Features

- **Habit Tracking (CRUD):** Create, complete, and manage habits seamlessly with real-time streak calculations.
- **Offline-First Persistence:** Local caching and data persistence powered by `shared_preferences`.
- **Dynamic Theming:** Native Dark Mode designed with a custom high-contrast color palette.
- **Daily Inspiration (WIP):** Daily motivational quotes fetched asynchronously from an external REST API via `Dio`.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management:** [Flutter Riverpod](https://riverpod.dev) (NotifierProvider pattern)
- **Networking:** [Dio](https://pub.dev/packages/dio)
- **Local Storage:** [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Navigation:** [GoRouter](https://pub.dev/packages/go_router)

### Project Structure (Feature-First)

```text
lib/
├── app.dart                   # MaterialApp, global dark theme configuration
├── main.dart                  # ProviderScope, async SharedPreferences initialization
│
├── core/                      # Shared global resources
│   ├── constants/             # Design tokens & color palettes (AppColors)
│   ├── network/               # Configured Dio HTTP client
│   ├── router/                # App route definitions
│   └── storage/               # Storage adapters and interfaces
│
└── features/                  # Vertical domain slices
    ├── quote/                 # Feature: Daily Quotes (Data & UI)
    └── habits/                # Feature: Habits Management
        ├── data/              # HabitRepository & JSON serialization
        ├── domain/            # Habit entity model
        └── presentation/      # UI components & Riverpod controllers
            ├── controllers/   # HabitsNotifier & state management
            ├── screens/       # Main views (HomeScreen, FormScreen)
            └── widgets/       # Modular UI components (HabitTile, etc.)
```

---

## 🚀 Getting Started

Follow these instructions to set up and run the project locally.

### Prerequisites

Ensure you have the following installed:

* **Flutter SDK:** `>=3.0.0`
* **Dart SDK:** `>=3.0.0`
* **IDE:** Android Studio, VS Code, or Xcode (for iOS builds)

---

### Installation & Run

**Install dependencies:**

```bash
flutter pub get
```

---

**Run the app:**

```bash
flutter run
```

---

**Run tests:**

```bash
flutter test
```
