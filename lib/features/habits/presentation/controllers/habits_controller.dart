import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/habit_repository.dart';
import '../../domain/habit.dart';

/// Provider per la data attualmente selezionata dall'utente nella Home
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(
  () {
    return SelectedDateNotifier();
  },
);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  void setDate(DateTime date) {
    state = DateTime(date.year, date.month, date.day);
  }
}

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

    // Pianifica la notifica se è stato impostato un orario
    if (habit.reminderTime != null) {
      await NotificationService().scheduleHabitNotification(habit);
    }
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    state = [
      for (final habit in state)
        if (habit.id == updatedHabit.id) updatedHabit else habit,
    ];
    await _repository.saveHabits(state);

    // Se l'orario esiste aggiorna la notifica, altrimenti rimuovila
    if (updatedHabit.reminderTime != null) {
      await NotificationService().scheduleHabitNotification(updatedHabit);
    } else {
      await NotificationService().cancelNotification(updatedHabit.id);
    }
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

    // Cancella la notifica programmata quando l'abitudine viene eliminata
    await NotificationService().cancelNotification(habitId);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
