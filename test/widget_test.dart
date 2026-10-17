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
    'Home PageView slide, Analytics detail pickers, and modern Create/Edit modal test',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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

      // 1. Verifica Home Screen e PageView slide per il cambio giorno
      expect(find.byType(PageView), findsOneWidget);
      expect(find.text("TODAY'S HABITS"), findsOneWidget);

      await tester.fling(
        find.byType(PageView),
        const Offset(-400, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text('HABITS FOR THIS DAY'), findsOneWidget);

      await tester.fling(
        find.byType(PageView),
        const Offset(400, 0),
        1000,
      );
      await tester.pumpAndSettle();
      expect(find.text("TODAY'S HABITS"), findsOneWidget);

      // 2. Naviga alla schermata Analytics e apri il dettaglio
      await tester.tap(find.byIcon(Icons.auto_graph_outlined));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Zone 2 Aerobic Base').last);
      await tester.pumpAndSettle();

      expect(find.text('Habit Detail & History'), findsOneWidget);

      // Verifica selettore Anno built-in per Annual Consistency
      await tester.ensureVisible(find.text('${now.year}'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('${now.year}'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // 3. Verifica modal Edit Habit (senza Choose Icon, con selettore icona accanto al nome)
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Edit Habit'), findsOneWidget);
      expect(find.text('Habit Name & Icon'), findsOneWidget);
      expect(find.text('Choose Icon'), findsNothing);

      // Chiudi il modal e torna indietro
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 4. Naviga alla schermata Settings e verifica il cambio tema (Light / Dark / System)
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
      expect(find.text('App Theme'), findsOneWidget);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(sharedPreferences.getString('app_theme_mode'), 'light');

      await tester.tap(find.text('System'));
      await tester.pumpAndSettle();
      expect(sharedPreferences.getString('app_theme_mode'), 'system');

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(sharedPreferences.getString('app_theme_mode'), 'dark');
    },
  );
}
