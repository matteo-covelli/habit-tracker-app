import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/habit_repository.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza SharedPreferences e Notifiche prima dell'avvio della UI
  final sharedPreferences = await SharedPreferences.getInstance();
  await NotificationService().init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const HabitTrackApp(),
    ),
  );
}
