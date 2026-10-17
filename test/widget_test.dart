import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:habit_tracker/app.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:habit_tracker/models/quote.dart';
import 'package:habit_tracker/services/habit_repository.dart';
import 'package:habit_tracker/services/quote_service.dart';
import 'package:dio/dio.dart';

class _FakeQuoteService extends QuoteService {
  _FakeQuoteService() : super(Dio());

  @override
  Future<Quote> fetchRandomQuote() async {
    return Quote.fallback();
  }
}

void main() {
  testWidgets(
    'Home swipe, Analytics detail calendar & consistency, and Profile screen test',
    (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final repo = HabitRepository(sharedPreferences);

      final now = DateTime.now();
      final todayIso =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      await repo.saveHabits([
        Habit(
          id: 'habit-1',
          title: 'Zone 2 Aerobic Base',
          iconCodePoint: Icons.directions_run.codePoint,
          goal: HabitGoal.build,
          frequencyDays: const [1, 2, 3, 4, 5, 6, 7],
          streakDays: 1,
          completedDates: [todayIso],
          startDate: '2024-01-01',
        ),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            quoteServiceProvider.overrideWithValue(_FakeQuoteService()),
          ],
          child: const HabitTrackApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verifica Home Screen e che il tap sull'abitudine NON apra il pannello di modifica
      expect(find.text("TODAY'S HABITS"), findsOneWidget);
      expect(find.text('Zone 2 Aerobic Base'), findsOneWidget);
      expect(find.text('1 of 1 Completed'), findsOneWidget);

      await tester.tap(find.text('Zone 2 Aerobic Base'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Habit'), findsNothing);
      expect(find.text('0 of 1 Completed'), findsOneWidget);

      // Ri-marca come completata
      await tester.tap(find.text('Zone 2 Aerobic Base'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 1 Completed'), findsOneWidget);

      // 2. Verifica swipe orizzontale nella Home per cambiare giorno
      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('HABITS FOR THIS DAY'), findsOneWidget);

      // Torna a oggi con swipe verso destra
      await tester.fling(
        find.byType(CustomScrollView).first,
        const Offset(400, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text("TODAY'S HABITS"), findsOneWidget);

      // 3. Naviga alla schermata Analytics
      await tester.tap(find.byIcon(Icons.auto_graph_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Habit Analytics'), findsOneWidget);
      expect(find.text('Zone 2 Aerobic Base'), findsWidgets);

      // Apri il dettaglio dell'abitudine
      await tester.tap(find.text('Zone 2 Aerobic Base').last);
      await tester.pumpAndSettle();

      expect(find.text('Habit Detail & History'), findsOneWidget);
      expect(find.text('Annual Consistency'), findsOneWidget);
      expect(find.text('1 days completed in ${now.year}'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.text('Pause Habit'), findsNothing);

      // Verifica apertura modifica dalla matita in alto
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Edit Habit'), findsOneWidget);

      // Chiudi il modal di modifica e torna indietro da Detail
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 4. Naviga alla schermata Profile
      await tester.tap(find.byIcon(Icons.person_outline));
      await tester.pumpAndSettle();

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('TOTAL HABITS COMPLETED'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    },
  );
}
