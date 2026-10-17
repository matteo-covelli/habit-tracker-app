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

### Project Structure

```text
lib/
├── app.dart                         # MaterialApp & global dark theme configuration
├── main.dart                        # ProviderScope, SharedPreferences & NotificationService init
├── constants/
│   └── app_colors.dart              # Design tokens & color palettes (AppColors)
├── models/
│   ├── habit.dart                   # Habit & HabitGoal domain models
│   └── quote.dart                   # Quote domain model
├── services/                        # Unified services directory
│   ├── habit_repository.dart        # Local storage persistence (SharedPreferences)
│   ├── notification_service.dart    # Local notifications scheduler
│   └── quote_service.dart           # Remote quote API service (Dio)
├── controllers/
│   ├── habits_controller.dart       # HabitsNotifier, SelectedDateNotifier & providers
│   └── quote_controller.dart        # QuoteNotifier provider
├── screens/
│   ├── main_shell_screen.dart       # Bottom navigation shell
│   ├── home_screen.dart             # Daily habits view with horizontal swipe navigation
│   ├── analytics_screen.dart        # Habit Analytics list with search & goal filters
│   ├── habit_detail_screen.dart     # Monthly interactive calendar, GitHub consistency & edit action
│   └── profile_screen.dart          # User profile & total completed habits counter
└── widgets/
    ├── add_habit_modal.dart         # Create / Edit habit bottom sheet
    ├── habit_tile.dart              # Daily habit completion card
    └── quote_card.dart              # Motivational quote card
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
