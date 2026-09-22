import 'package:flutter/material.dart';

enum HabitGoal { build, breakHabit, trackOnly }

class Habit {
  final String id;
  final String title;
  final String? subtitle;
  final int iconCodePoint;
  final HabitGoal goal;
  final List<int> frequencyDays; // 1 = Lun, 7 = Dom (standard DateTime.weekday)
  final int streakDays;
  final List<String> completedDates; // Date in formato YYYY-MM-DD
  final String? reminderTime;

  const Habit({
    required this.id,
    required this.title,
    this.subtitle,
    required this.iconCodePoint,
    this.goal = HabitGoal.build,
    this.frequencyDays = const [1, 2, 3, 4, 5, 6, 7],
    this.streakDays = 0,
    this.completedDates = const [],
    this.reminderTime,
  });

  bool isCompletedOn(DateTime date) {
    final dateKey = _formatDate(date);
    return completedDates.contains(dateKey);
  }

  Habit copyWith({
    String? id,
    String? title,
    String? subtitle,
    int? iconCodePoint,
    HabitGoal? goal,
    List<int>? frequencyDays,
    int? streakDays,
    List<String>? completedDates,
    String? reminderTime,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      goal: goal ?? this.goal,
      frequencyDays: frequencyDays ?? this.frequencyDays,
      streakDays: streakDays ?? this.streakDays,
      completedDates: completedDates ?? this.completedDates,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'iconCodePoint': iconCodePoint,
      'goal': goal.name,
      'frequencyDays': frequencyDays,
      'streakDays': streakDays,
      'completedDates': completedDates,
      'reminderTime': reminderTime,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String?,
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
    );
  }

  static String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
