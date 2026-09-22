import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/habit.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences non ancora inizializzato');
});

final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HabitRepository(prefs);
});

class HabitRepository {
  static const _habitsKey = 'habits_data';
  final SharedPreferences _prefs;

  HabitRepository(this._prefs);

  List<Habit> loadHabits() {
    final rawJson = _prefs.getString(_habitsKey);
    if (rawJson == null || rawJson.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> decodedList = jsonDecode(rawJson);
      return decodedList
          .map((item) => Habit.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final rawJson = jsonEncode(habits.map((h) => h.toJson()).toList());
    await _prefs.setString(_habitsKey, rawJson);
  }
}
