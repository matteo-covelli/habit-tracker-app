import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../models/habit.dart';

class HabitTile extends ConsumerWidget {
  final Habit habit;
  final DateTime? date;

  const HabitTile({super.key, required this.habit, this.date});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime targetDate = date ?? ref.watch(selectedDateProvider);
    final isCompleted = habit.isCompletedOn(targetDate);

    void toggleCompletion() {
      ref
          .read(habitsProvider.notifier)
          .toggleHabitCompletion(habit.id, targetDate);
    }

    return GestureDetector(
      onTap: toggleCompletion,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompleted
                ? Colors.transparent
                : AppColors.cardBorder.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icona tonda dell'abitudine
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getIconBackgroundColor(
                  habit.iconCodePoint,
                  isCompleted,
                ),
              ),
              child: Icon(
                IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: _getIconForegroundColor(
                  habit.iconCodePoint,
                  isCompleted,
                ),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),

            // Titolo
            Expanded(
              child: Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),

            // Pillola Streak con eventuale fiamma
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF33271C),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${habit.streakDays}d',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  if (habit.streakDays >= 7) ...[
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: AppColors.accentOrange,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Pulsante circolare di check
            GestureDetector(
              onTap: toggleCompletion,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? AppColors.accentGreen
                      : const Color(0xFF222B3D),
                  border: Border.all(
                    color: isCompleted
                        ? AppColors.accentGreen
                        : const Color(0xFF344159),
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 20,
                        color: Color(0xFF0F131D),
                      )
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getIconBackgroundColor(int codePoint, bool isCompleted) {
    if (codePoint == Icons.water_drop.codePoint) return const Color(0xFF818CF8);
    if (codePoint == Icons.self_improvement.codePoint) {
      return const Color(0xFF10B981);
    }
    return const Color(0xFF263145);
  }

  Color _getIconForegroundColor(int codePoint, bool isCompleted) {
    if (codePoint == Icons.water_drop.codePoint ||
        codePoint == Icons.self_improvement.codePoint) {
      return Colors.white;
    }
    return const Color(0xFFF59E0B);
  }
}
