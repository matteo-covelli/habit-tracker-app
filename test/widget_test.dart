import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/app.dart';
import 'package:habit_tracker/features/habits/data/habit_repository.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Mock dei valori iniziali per SharedPreferences
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    // Avvio dell'app incapsulata nel ProviderScope con override
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const HabitTrackApp(),
      ),
    );

    // Verifica che l'interfaccia iniziale venga caricata
    expect(find.text('Habit Tracker Ready'), findsOneWidget);
  });
}
