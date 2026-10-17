import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/habit_tile.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _selectDate(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryButton,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(selectedDateProvider.notifier).setDate(picked);
    }
  }

  void _handleHorizontalSwipe(DragEndDetails details, WidgetRef ref) {
    final velocity = details.primaryVelocity ?? 0;
    // Swipe verso sinistra -> giorno successivo
    if (velocity < -150) {
      ref.read(selectedDateProvider.notifier).nextDay();
    }
    // Swipe verso destra -> giorno precedente
    else if (velocity > 150) {
      ref.read(selectedDateProvider.notifier).previousDay();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final visibleHabits = ref.watch(visibleHabitsProvider);

    final completedCount = visibleHabits
        .where((h) => h.isCompletedOn(selectedDate))
        .length;
    final totalCount = visibleHabits.length;

    final dateFormatted = DateFormat(
      'EEEE, MMM d',
    ).format(selectedDate).toUpperCase();

    final now = DateTime.now();
    final isToday =
        selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            dateFormatted,
            key: ValueKey(dateFormatted),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => _selectDate(context, ref, selectedDate),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryButton,
        foregroundColor: AppColors.primaryButtonText,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.add, size: 22),
        label: const Text(
          'NEW HABIT',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            fontSize: 13,
          ),
        ),
        onPressed: () => AddHabitModal.show(context),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (details) => _handleHorizontalSwipe(details, ref),
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: QuoteCard()),

            // Intestazione con contatore completati del giorno
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isToday ? "TODAY'S HABITS" : "HABITS FOR THIS DAY",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '$completedCount of $totalCount Completed',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Lista abitudini filtrate
            if (visibleHabits.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    isToday
                        ? 'No habits yet.\nTap + NEW HABIT to start!'
                        : 'No habits scheduled for this day.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => HabitTile(habit: visibleHabits[index]),
                  childCount: visibleHabits.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }
}
