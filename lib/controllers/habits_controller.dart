import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/habit.dart';
import '../services/habit_repository.dart';
import '../services/notification_service.dart';

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

  void nextDay() {
    state = DateTime(state.year, state.month, state.day + 1);
  }

  void previousDay() {
    state = DateTime(state.year, state.month, state.day - 1);
  }
}

final habitsProvider = NotifierProvider<HabitsNotifier, List<Habit>>(() {
  return HabitsNotifier();
});

/// Provider reattivo che restituisce solo le abitudini visibili nel giorno selezionato
final visibleHabitsProvider = Provider<List<Habit>>((ref) {
  final selectedDate = ref.watch(selectedDateProvider);
  final allHabits = ref.watch(habitsProvider);
  return allHabits.where((habit) => habit.isVisibleOn(selectedDate)).toList();
});

/// Provider che calcola il numero totale di completamenti registrati su tutte le abitudini
final totalCompletedHabitsProvider = Provider<int>((ref) {
  final allHabits = ref.watch(habitsProvider);
  return allHabits.fold<int>(
    0,
    (sum, habit) => sum + habit.completedDates.length,
  );
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

    // Notifica solo se il toggle è attivo e c'è almeno un giorno selezionato
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

    // Se il promemoria è attivo aggiorna i giorni schedulati, altrimenti cancella
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

    await NotificationService().cancelNotification(habitId);
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
