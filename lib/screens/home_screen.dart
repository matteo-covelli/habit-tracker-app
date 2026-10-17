import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../widgets/add_habit_modal.dart';
import '../widgets/habit_tile.dart';
import '../widgets/quote_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const int _anchorPage = 10000;
  late final DateTime _anchorDate;
  late final PageController _pageController;
  int _lastPage = _anchorPage;
  int _slideDirection = 1; // 1 = avanti (slide da destra), -1 = indietro

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _anchorDate = DateTime(now.year, now.month, now.day);
    _pageController = PageController(initialPage: _anchorPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateForPage(int pageIndex) {
    return DateTime(
      _anchorDate.year,
      _anchorDate.month,
      _anchorDate.day + (pageIndex - _anchorPage),
    );
  }

  int _pageForDate(DateTime date) {
    final targetUtc = DateTime.utc(date.year, date.month, date.day);
    final anchorUtc = DateTime.utc(
      _anchorDate.year,
      _anchorDate.month,
      _anchorDate.day,
    );
    return _anchorPage + targetUtc.difference(anchorUtc).inDays;
  }

  Future<void> _animateToDate(DateTime targetDate) async {
    final targetPage = _pageForDate(targetDate);
    if (!_pageController.hasClients) return;

    final currentPage = _pageController.page?.round() ?? _lastPage;
    if (targetPage == currentPage) return;

    setState(() {
      _slideDirection = targetPage > currentPage ? 1 : -1;
    });

    // Se la data scelta dal calendario è lontana molti giorni, salta alla pagina adiacente
    // prima di animare, così lo slide dura sempre 1 pagina fluida
    if ((targetPage - currentPage).abs() > 2) {
      _pageController.jumpToPage(
        targetPage > currentPage ? targetPage - 1 : targetPage + 1,
      );
    }

    await _pageController.animateToPage(
      targetPage,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _selectDate(
    BuildContext context,
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
              primary: AppColors.accentGreen,
              onPrimary: Color(0xFF0F131D),
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
      await _animateToDate(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    final allHabits = ref.watch(habitsProvider);

    final dateFormatted = DateFormat(
      'EEEE, MMM d',
    ).format(selectedDate).toUpperCase();

    final now = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        titleSpacing: 20,
        title: ClipRect(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            transitionBuilder: (child, animation) {
              final isIncoming = child.key == ValueKey(dateFormatted);
              final beginOffset = isIncoming
                  ? Offset(_slideDirection.toDouble(), 0)
                  : Offset(-_slideDirection.toDouble(), 0);
              return SlideTransition(
                position: Tween<Offset>(
                  begin: beginOffset,
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
                ),
                child: FadeTransition(opacity: animation, child: child),
              );
            },
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
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () => _selectDate(context, selectedDate),
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
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (pageIndex) {
          final newDate = _dateForPage(pageIndex);
          setState(() {
            _slideDirection = pageIndex >= _lastPage ? 1 : -1;
            _lastPage = pageIndex;
          });
          ref.read(selectedDateProvider.notifier).setDate(newDate);
        },
        itemBuilder: (context, pageIndex) {
          final pageDate = _dateForPage(pageIndex);
          final visibleHabits = allHabits
              .where((habit) => habit.isVisibleOn(pageDate))
              .toList();

          final completedCount = visibleHabits
              .where((h) => h.isCompletedOn(pageDate))
              .length;
          final totalCount = visibleHabits.length;

          final isToday =
              pageDate.year == now.year &&
              pageDate.month == now.month &&
              pageDate.day == now.day;

          return CustomScrollView(
            key: PageStorageKey('home_day_${pageDate.toIso8601String()}'),
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
                      Expanded(
                        child: Text(
                          isToday ? "TODAY'S HABITS" : "HABITS FOR THIS DAY",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
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

              // Lista abitudini filtrate per il giorno della pagina
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
                    (context, index) => HabitTile(
                      habit: visibleHabits[index],
                      date: pageDate,
                    ),
                    childCount: visibleHabits.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          );
        },
      ),
    );
  }
}
