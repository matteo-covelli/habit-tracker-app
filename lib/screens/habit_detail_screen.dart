import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../models/habit.dart';
import '../widgets/add_habit_modal.dart';

class HabitDetailScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends ConsumerState<HabitDetailScreen> {
  late DateTime _focusedMonth;
  late int _selectedYear;

  static const List<String> _weekdayHeaders = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  static const List<String> _monthShortNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedYear = now.year;
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _previousYear() {
    setState(() {
      _selectedYear -= 1;
    });
  }

  void _nextYear() {
    setState(() {
      _selectedYear += 1;
    });
  }

  Future<void> _editHabit(Habit habit) async {
    final deleted = await AddHabitModal.show(context, habitToEdit: habit);
    if (deleted == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final habits = ref.watch(habitsProvider);
    final habit = habits.where((h) => h.id == widget.habitId).firstOrNull;

    if (habit == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
        title: const Text(
          'Habit Detail & History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Habit',
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.textPrimary,
              size: 22,
            ),
            onPressed: () => _editHabit(habit),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          children: [
            _buildHeaderCard(habit),
            const SizedBox(height: 18),
            _buildMonthlyCalendarCard(habit),
            const SizedBox(height: 18),
            _buildAnnualConsistencyCard(habit),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Habit habit) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF171E2C),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF232D42), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF232B3E),
            ),
            child: Icon(
              IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: AppColors.primaryButton,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF33261B),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFF4D3822),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        '${habit.streakDays} Days',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyCalendarCard(Habit habit) {
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    // 1 = Monday -> 0 leading empty cells; 7 = Sunday -> 6 leading empty cells
    final leadingEmptyDays = firstDayOfMonth.weekday - 1;
    final totalGridCells = leadingEmptyDays + daysInMonth;

    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C28),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF212B3E), width: 1),
      ),
      child: Column(
        children: [
          // Intestazione mese + frecce
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: AppColors.primaryButton,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    monthLabel,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0E131D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: _previousMonth,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: _nextMonth,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Giorni della settimana M T W T F S S
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _weekdayHeaders
                .map(
                  (label) => SizedBox(
                    width: 38,
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),

          // Griglia dei giorni del mese
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalGridCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              if (index < leadingEmptyDays) {
                return const SizedBox.shrink();
              }

              final dayNumber = index - leadingEmptyDays + 1;
              final date = DateTime(
                _focusedMonth.year,
                _focusedMonth.month,
                dayNumber,
              );
              final isCompleted = habit.isCompletedOn(date);
              final isToday =
                  date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;

              return GestureDetector(
                onTap: () {
                  ref
                      .read(habitsProvider.notifier)
                      .toggleHabitCompletion(habit.id, date);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted
                        ? AppColors.accentGreen
                        : const Color(0xFF232B3C),
                    border: isToday
                        ? Border.all(
                            color: isCompleted
                                ? Colors.white
                                : AppColors.primaryButton,
                            width: 2,
                          )
                        : null,
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: AppColors.primaryButton.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isCompleted
                            ? const Color(0xFF0F131D)
                            : isToday
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Istruzione tap
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 16,
                color: AppColors.primaryButton,
              ),
              SizedBox(width: 6),
              Text(
                'Tap any date to mark or unmark completion',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Legenda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF101520),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCalendarLegendItem(
                  color: AppColors.accentGreen,
                  label: 'Completed',
                ),
                _buildCalendarLegendItem(
                  color: AppColors.primaryButton,
                  hasGlowRing: true,
                  label: 'Today',
                ),
                _buildCalendarLegendItem(
                  color: const Color(0xFF283144),
                  label: 'Unmarked',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegendItem({
    required Color color,
    required String label,
    bool hasGlowRing = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: hasGlowRing
                ? Border.all(color: Colors.white70, width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualConsistencyCard(Habit habit) {
    final yearPrefix = '$_selectedYear-';
    final completedInYear = habit.completedDates
        .where((d) => d.startsWith(yearPrefix))
        .length;

    // Calcola la griglia stile GitHub per l'anno selezionato
    final firstDayOfYear = DateTime(_selectedYear, 1, 1);
    final startGridDate = firstDayOfYear.subtract(
      Duration(days: firstDayOfYear.weekday - 1),
    );
    final lastDayOfYear = DateTime(_selectedYear, 12, 31);
    final endGridDate = lastDayOfYear.add(
      Duration(days: 7 - lastDayOfYear.weekday),
    );

    final totalDays = endGridDate.difference(startGridDate).inDays + 1;
    final totalWeeks = totalDays ~/ 7;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF151C28),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF212B3E), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intestazione + selettore anno
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Annual Consistency',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E131D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.chevron_left,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: _previousYear,
                    ),
                    Text(
                      '$_selectedYear',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryButton,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 18,
                      ),
                      onPressed: _nextYear,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Contatore giorni completati nell'anno
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF101520),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.verified_outlined,
                  color: AppColors.accentGreen,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Text(
                  '$completedInYear days completed in $_selectedYear',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Griglia contributi stile GitHub
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etichette giorni a sinistra (M, W, F)
              Padding(
                padding: const EdgeInsets.only(top: 20, right: 8),
                child: Column(
                  children: List.generate(7, (dayRow) {
                    String label = '';
                    if (dayRow == 0) label = 'M';
                    if (dayRow == 2) label = 'W';
                    if (dayRow == 4) label = 'F';
                    return Container(
                      height: 13,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // Colonne settimane scorrevoli orizzontalmente
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Riga mesi in alto
                      Row(
                        children: List.generate(totalWeeks, (weekIndex) {
                          final monthLabel = _getMonthLabelForWeek(
                            startGridDate,
                            weekIndex,
                          );
                          return SizedBox(
                            width: 17,
                            height: 18,
                            child: OverflowBox(
                              alignment: Alignment.centerLeft,
                              maxWidth: 36,
                              child: Text(
                                monthLabel ?? '',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 2),

                      // Matrice 7 righe x totalWeeks colonne
                      Row(
                        children: List.generate(totalWeeks, (weekIndex) {
                          return Column(
                            children: List.generate(7, (dayIndex) {
                              final cellDate = DateTime(
                                startGridDate.year,
                                startGridDate.month,
                                startGridDate.day + (weekIndex * 7) + dayIndex,
                              );
                              final isInSelectedYear =
                                  cellDate.year == _selectedYear;
                              final isCompleted =
                                  isInSelectedYear &&
                                  habit.isCompletedOn(cellDate);

                              return GestureDetector(
                                onTap: isInSelectedYear
                                    ? () {
                                        ref
                                            .read(habitsProvider.notifier)
                                            .toggleHabitCompletion(
                                              habit.id,
                                              cellDate,
                                            );
                                      }
                                    : null,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: !isInSelectedYear
                                        ? Colors.transparent
                                        : isCompleted
                                        ? AppColors.accentGreen
                                        : const Color(0xFF263042),
                                    borderRadius: BorderRadius.circular(3.5),
                                  ),
                                ),
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Legenda Unmarked / Marked
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildConsistencyLegendItem(
                color: const Color(0xFF263042),
                label: 'Unmarked',
              ),
              const SizedBox(width: 14),
              _buildConsistencyLegendItem(
                color: AppColors.accentGreen,
                label: 'Marked',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _getMonthLabelForWeek(DateTime startGridDate, int weekIndex) {
    for (int d = 0; d < 7; d++) {
      final date = DateTime(
        startGridDate.year,
        startGridDate.month,
        startGridDate.day + (weekIndex * 7) + d,
      );
      if (date.year == _selectedYear && date.day == 1) {
        // Evita sovrapposizioni se la prima settimana ha già mostrato Jan
        return _monthShortNames[date.month - 1];
      }
    }
    return null;
  }

  Widget _buildConsistencyLegendItem({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2.5),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
