import 'package:flutter/material.dart';

// Oggetto sentinella per gestire l'assegnazione esplicita di null in copyWith
const Object _sentinel = Object();

enum HabitGoal { build, breakHabit, trackOnly }

class Habit {
  final String id;
  final String title;
  final int iconCodePoint;
  final HabitGoal goal;
  final List<int> frequencyDays; // 1 = Lun, 7 = Dom (standard DateTime.weekday)
  final int streakDays;
  final List<String> completedDates; // Date in formato YYYY-MM-DD
  final String? reminderTime;
  final String startDate; // Data di inizio in formato YYYY-MM-DD

  const Habit({
    required this.id,
    required this.title,
    required this.iconCodePoint,
    this.goal = HabitGoal.build,
    this.frequencyDays = const [1, 2, 3, 4, 5, 6, 7],
    this.streakDays = 0,
    this.completedDates = const [],
    this.reminderTime,
    required this.startDate,
  });

  bool isCompletedOn(DateTime date) {
    final dateKey = _formatDate(date);
    return completedDates.contains(dateKey);
  }

  /// Verifica se l'abitudine è attiva nella data specificata
  bool isVisibleOn(DateTime date) {
    final start = _parseDate(startDate);
    final target = DateTime(date.year, date.month, date.day);

    // 1. Non deve comparire prima della data di inizio
    if (target.isBefore(start)) {
      return false;
    }

    // 2. Deve essere programmata per questo giorno della settimana
    return frequencyDays.contains(date.weekday);
  }

  Habit copyWith({
    String? id,
    String? title,
    int? iconCodePoint,
    HabitGoal? goal,
    List<int>? frequencyDays,
    int? streakDays,
    List<String>? completedDates,
    Object? reminderTime = _sentinel,
    String? startDate,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      goal: goal ?? this.goal,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      streakDays: streakDays ?? this.streakDays,
      completedDates: completedDates ?? this.completedDates,
      reminderTime: identical(reminderTime, _sentinel)
          ? this.reminderTime
          : reminderTime as String?,
      startDate: startDate ?? this.startDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'iconCodePoint': iconCodePoint,
      'goal': goal.name,
      'frequencyDays': frequencyDays,
      'streakDays': streakDays,
      'completedDates': completedDates,
      'reminderTime': reminderTime,
      'startDate': startDate,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      iconCodePoint:
          json['iconCodePoint'] as int? ?? Icons.fitness_center.codePoint,
      goal: HabitGoal.values.firstWhere(
        (e) => e.name == json['goal'],
        orElse: () => HabitGoal.build,
      ),
      frequencyDays: List<int>.from(
        json['frequencyDays'] ?? [1, 2, 3, 4, 5, 6, 7],
      ),
      streakDays: json['streakDays'] as int? ?? 0,
      completedDates: List<String>.from(json['completedDates'] ?? []),
      reminderTime: json['reminderTime'] as String?,
      startDate: json['startDate'] as String? ?? _formatDate(DateTime.now()),
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }
  }
}
