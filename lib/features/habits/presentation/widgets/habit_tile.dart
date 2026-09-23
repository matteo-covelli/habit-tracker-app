import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/habit.dart';
import '../controllers/habits_controller.dart';
import 'add_habit_modal.dart';

class HabitTile extends ConsumerWidget {
  final Habit habit;

  const HabitTile({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();
    final isCompletedToday = habit.isCompletedOn(now);

    return GestureDetector(
      onTap: () => AddHabitModal.show(context, habitToEdit: habit),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isCompletedToday
                ? Colors.transparent
                : AppColors.cardBorder.withOpacity(0.5),
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
                  isCompletedToday,
                ),
              ),
              child: Icon(
                IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: _getIconForegroundColor(
                  habit.iconCodePoint,
                  isCompletedToday,
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
                  color: isCompletedToday
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                  decoration: isCompletedToday
                      ? TextDecoration.lineThrough
                      : null,
                  decorationColor: AppColors.textSecondary,
                ),
              ),
            ),

            // Pillola Streak con eventuale fiamma
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF33271C), // Badge ambrato scuro
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
              onTap: () {
                ref
                    .read(habitsProvider.notifier)
                    .toggleHabitCompletion(habit.id, now);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompletedToday
                      ? AppColors.accentGreen
                      : const Color(0xFF222B3D),
                  border: Border.all(
                    color: isCompletedToday
                        ? AppColors.accentGreen
                        : const Color(0xFF344159),
                    width: 2,
                  ),
                ),
                child: isCompletedToday
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
