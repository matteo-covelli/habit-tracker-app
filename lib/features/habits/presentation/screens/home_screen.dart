import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/habit_tile.dart';
import '../../../quote/presentation/widgets/quote_card.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allHabits = ref.watch(habitsProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Mostra solo gli habit validi per la data selezionata
    final visibleHabits = allHabits
        .where((h) => h.isVisibleOn(selectedDate))
        .toList();
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
        title: Text(
          dateFormatted,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: AppColors.textPrimary,
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
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B0E17),
          border: Border(top: BorderSide(color: Color(0xFF1E2638), width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF252D42),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.home, color: Colors.white, size: 24),
            ),
            IconButton(
              icon: const Icon(
                Icons.show_chart,
                color: AppColors.textSecondary,
                size: 24,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.person_outline,
                color: AppColors.textSecondary,
                size: 24,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
                size: 24,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: QuoteCard()),

          // Sezione Header con conteggio per la data selezionata
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
    );
  }
}
