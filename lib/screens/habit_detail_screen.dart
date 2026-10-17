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

  Future<void> _selectMonthAndYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _focusedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => AppColors.pickerTheme(context, child),
    );

    if (picked != null) {
      setState(() {
        _focusedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  Future<void> _selectConsistencyYear() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(_selectedYear, now.month, 1),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
      builder: (context, child) => AppColors.pickerTheme(context, child),
    );

    if (picked != null) {
      setState(() {
        _selectedYear = picked.year;
      });
    }
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
      return Scaffold(backgroundColor: AppColors.bg(context));
    }

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      appBar: AppBar(
        backgroundColor: AppColors.bg(context),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textMain(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 4,
        title: Text(
          'Habit Detail & History',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: AppColors.textMain(context),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit Habit',
            icon: Icon(
              Icons.edit_outlined,
              color: AppColors.textMain(context),
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
            _buildHeaderCard(context, habit),
            const SizedBox(height: 18),
            _buildMonthlyCalendarCard(context, habit),
            const SizedBox(height: 18),
            _buildAnnualConsistencyCard(context, habit),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, Habit habit) {
    final isDark = AppColors.isDark(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171E2C) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF232D42) : AppColors.border(context),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF232B3E)
                  : AppColors.accentPrimary(context).withValues(alpha: 0.12),
            ),
            child: Icon(
              IconData(habit.iconCodePoint, fontFamily: 'MaterialIcons'),
              color: AppColors.accentPrimary(context),
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
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textMain(context),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.streakBg(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: AppColors.streakBorder(context),
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
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.streakText(context),
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

  Widget _buildMonthlyCalendarCard(BuildContext context, Habit habit) {
    final isDark = AppColors.isDark(context);
    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedMonth.year,
      _focusedMonth.month,
    );
    final leadingEmptyDays = firstDayOfMonth.weekday - 1;
    final totalGridCells = leadingEmptyDays + daysInMonth;

    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        children: [
          // Intestazione mese + selettore mese/anno + frecce
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: GestureDetector(
                  onTap: _selectMonthAndYear,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.subtleBg(context),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF253047)
                            : AppColors.border(context),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_outlined,
                          color: AppColors.accentPrimary(context),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            monthLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textMain(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.accentPrimary(context),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.subtleBg(context),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.chevron_left,
                        color: AppColors.textSub(context),
                        size: 20,
                      ),
                      onPressed: _previousMonth,
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        Icons.chevron_right,
                        color: AppColors.textSub(context),
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
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSub(context),
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
                        : AppColors.cellUnmarked(context),
                    border: isToday
                        ? Border.all(
                            color: isCompleted
                                ? Colors.white
                                : AppColors.accentPrimary(context),
                            width: 2,
                          )
                        : null,
                    boxShadow: isToday
                        ? [
                            BoxShadow(
                              color: AppColors.accentPrimary(
                                context,
                              ).withValues(alpha: 0.35),
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
                            ? AppColors.textMain(context)
                            : AppColors.textSub(context),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 18),

          // Istruzione tap
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 16,
                color: AppColors.accentPrimary(context),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'Tap any date to mark or unmark completion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSub(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Legenda
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF101520)
                  : AppColors.subtleBg(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceAround,
              spacing: 12,
              runSpacing: 6,
              children: [
                _buildCalendarLegendItem(
                  context: context,
                  color: AppColors.accentGreen,
                  label: 'Completed',
                ),
                _buildCalendarLegendItem(
                  context: context,
                  color: AppColors.accentPrimary(context),
                  hasGlowRing: true,
                  label: 'Today',
                ),
                _buildCalendarLegendItem(
                  context: context,
                  color: isDark
                      ? const Color(0xFF283144)
                      : const Color(0xFFCBD5E1),
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
    required BuildContext context,
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
                ? Border.all(
                    color: AppColors.isDark(context)
                        ? Colors.white70
                        : Colors.white,
                    width: 1.5,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSub(context),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnualConsistencyCard(BuildContext context, Habit habit) {
    final isDark = AppColors.isDark(context);
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
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border(context), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Intestazione + selettore anno interattivo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Annual Consistency',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain(context),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _selectConsistencyYear,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.subtleBg(context),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF253047)
                          : AppColors.border(context),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 16,
                        color: AppColors.accentPrimary(context),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$_selectedYear',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentPrimary(context),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppColors.accentPrimary(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Contatore giorni completati nell'anno
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF101520)
                  : AppColors.subtleBg(context),
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
                Expanded(
                  child: Text(
                    '$completedInYear days completed in $_selectedYear',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMain(context),
                    ),
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
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSub(context),
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
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSub(context),
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
                                        : (isDark
                                              ? const Color(0xFF263042)
                                              : const Color(0xFFE2E8F0)),
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
                context: context,
                color: isDark
                    ? const Color(0xFF263042)
                    : const Color(0xFFE2E8F0),
                label: 'Unmarked',
              ),
              const SizedBox(width: 14),
              _buildConsistencyLegendItem(
                context: context,
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
        return _monthShortNames[date.month - 1];
      }
    }
    return null;
  }

  Widget _buildConsistencyLegendItem({
    required BuildContext context,
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
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSub(context),
          ),
        ),
      ],
    );
  }
}
