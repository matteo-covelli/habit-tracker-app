import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/habit_repository.dart';
import '../../domain/habit.dart';

final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(() {
  return HabitsNotifier();
});

class HabitsNotifier extends Notifier<List<Habit>> {
  late final HabitRepository _repository;

  @override
  List<Habit> build() {
    _repository = ref.watch(habitRepositoryProvider);
    return _repository.loadHabits();
  }

  Future<void> addHabit(Habit habit) async {
    state = [...state, habit];
    await _repository.saveHabits(state);
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    final dateKey = _formatDate(date);

    state = state.map((habit) {
      if (habit.id != habitId) return habit;

      final isAlreadyCompleted = habit.completedDates.contains(dateKey);
      List<String> updatedDates;
      int updatedStreak = habit.streakDays;

      if (isAlreadyCompleted) {
        updatedDates = habit.completedDates.where((d) => d != dateKey).toList();
        if (updatedStreak > 0) updatedStreak -= 1;
      } else {
        updatedDates = [...habit.completedDates, dateKey];
        updatedStreak += 1;
      }

      return habit.copyWith(
        completedDates: updatedDates,
        streakDays: updatedStreak,
      );
    }).toList();

    await _repository.saveHabits(state);
  }

  Future<void> deleteHabit(String habitId) async {
    state = state.where((habit) => habit.id != habitId).toList();
    await _repository.saveHabits(state);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
