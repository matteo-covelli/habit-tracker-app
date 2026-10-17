import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../models/habit.dart';
import 'habit_detail_screen.dart';

enum _AnalyticsFilter { all, build, breakHabit }

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  final TextEditingController _searchController = TextEditingController();
  _AnalyticsFilter _selectedFilter = _AnalyticsFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allHabits = ref.watch(habitsProvider);

    final filteredHabits = allHabits.where((habit) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          habit.title.toLowerCase().contains(_searchQuery);
      if (!matchesSearch) return false;

      switch (_selectedFilter) {
        case _AnalyticsFilter.all:
          return true;
        case _AnalyticsFilter.build:
          return habit.goal == HabitGoal.build;
        case _AnalyticsFilter.breakHabit:
          return habit.goal == HabitGoal.breakHabit;
      }
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Habit Analytics',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Select a habit to inspect calendar continuity and historical adherence.',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Barra di ricerca
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A0D15),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF192132),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: AppColors.textSecondary,
                            size: 20,
                          ),
                          hintText: 'Filter habits by title or tag...',
                          hintStyle: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Filtri ALL / BUILD / BREAK
                    Row(
                      children: [
                        _buildFilterChip(_AnalyticsFilter.all, 'ALL'),
                        const SizedBox(width: 8),
                        _buildFilterChip(_AnalyticsFilter.build, 'BUILD'),
                        const SizedBox(width: 8),
                        _buildFilterChip(_AnalyticsFilter.breakHabit, 'BREAK'),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            if (filteredHabits.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No habits found.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final habit = filteredHabits[index];
                    return _AnalyticsHabitCard(
                      habit: habit,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                HabitDetailScreen(habitId: habit.id),
                          ),
                        );
                      },
                    );
                  }, childCount: filteredHabits.length),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(_AnalyticsFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryButton : const Color(0xFF141A26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryButton
                : const Color(0xFF222B3D),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: isSelected ? AppColors.primaryButtonText : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _AnalyticsHabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;

  const _AnalyticsHabitCard({required this.habit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final iconColor = AppColors.getHabitIconColor(habit.iconCodePoint);
    final iconBgColor = AppColors.getHabitIconBgColor(habit.iconCodePoint);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: const Color(0xFF151C28),
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: const Color(0xFF212B3E), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconBgColor,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0.5,
                  ),
                ],
              ),
              child: Icon(
                IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
                color: iconColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                habit.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
