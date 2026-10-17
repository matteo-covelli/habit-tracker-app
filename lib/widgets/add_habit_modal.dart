import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';
import '../models/habit.dart';

class _IconOption {
  final IconData icon;
  final String name;
  final String category;

  const _IconOption(this.icon, this.name, this.category);
}

const List<_IconOption> _allSystemIcons = [
  // Fitness & Sport
  _IconOption(Icons.directions_run, 'Run / Cardio', 'Fitness'),
  _IconOption(Icons.fitness_center, 'Gym / Weights', 'Fitness'),
  _IconOption(Icons.directions_bike, 'Cycling', 'Fitness'),
  _IconOption(Icons.pool, 'Swimming', 'Fitness'),
  _IconOption(Icons.sports_basketball, 'Basketball', 'Fitness'),
  _IconOption(Icons.sports_soccer, 'Soccer', 'Fitness'),
  _IconOption(Icons.sports_tennis, 'Tennis', 'Fitness'),
  _IconOption(Icons.sports_martial_arts, 'Martial Arts', 'Fitness'),
  _IconOption(Icons.sports_gymnastics, 'Stretching', 'Fitness'),
  _IconOption(Icons.hiking, 'Hiking / Walk', 'Fitness'),

  // Wellness & Salute
  _IconOption(Icons.self_improvement, 'Meditation / Yoga', 'Wellness'),
  _IconOption(Icons.water_drop, 'Drink Water', 'Wellness'),
  _IconOption(Icons.nightlight_round, 'Sleep Early', 'Wellness'),
  _IconOption(Icons.favorite, 'Health / Cardio', 'Wellness'),
  _IconOption(Icons.spa, 'Mindfulness / Spa', 'Wellness'),
  _IconOption(Icons.medication, 'Vitamins / Meds', 'Wellness'),
  _IconOption(Icons.monitor_heart, 'Heart Rate', 'Wellness'),
  _IconOption(Icons.no_food, 'Fasting / No Junk', 'Wellness'),
  _IconOption(Icons.smoke_free, 'No Smoking', 'Wellness'),
  _IconOption(Icons.no_drinks, 'No Alcohol', 'Wellness'),
  _IconOption(Icons.psychology, 'Mental Health', 'Wellness'),
  _IconOption(Icons.sunny, 'Morning Sunlight', 'Wellness'),

  // Studio & Lavoro
  _IconOption(Icons.menu_book, 'Reading', 'Study & Work'),
  _IconOption(Icons.code, 'Coding', 'Study & Work'),
  _IconOption(Icons.school, 'Study / Course', 'Study & Work'),
  _IconOption(Icons.edit_note, 'Journaling / Write', 'Study & Work'),
  _IconOption(Icons.translate, 'Language Learning', 'Study & Work'),
  _IconOption(Icons.laptop_mac, 'Deep Work', 'Study & Work'),
  _IconOption(Icons.lightbulb_outline, 'Brainstorming', 'Study & Work'),
  _IconOption(Icons.podcasts, 'Educational Podcast', 'Study & Work'),
  _IconOption(Icons.calculate, 'Math / Problem Solving', 'Study & Work'),
  _IconOption(Icons.work_outline, 'Career Task', 'Study & Work'),

  // Lifestyle & Casa
  _IconOption(Icons.alarm, 'Wake Up Early', 'Lifestyle'),
  _IconOption(Icons.restaurant, 'Healthy Meal', 'Lifestyle'),
  _IconOption(Icons.coffee, 'Coffee Limit', 'Lifestyle'),
  _IconOption(Icons.cleaning_services, 'Clean Room', 'Lifestyle'),
  _IconOption(Icons.savings, 'Save Money', 'Lifestyle'),
  _IconOption(Icons.music_note, 'Practice Music', 'Lifestyle'),
  _IconOption(Icons.brush, 'Drawing / Art', 'Lifestyle'),
  _IconOption(Icons.camera_alt_outlined, 'Photography', 'Lifestyle'),
  _IconOption(Icons.pets, 'Walk the Pet', 'Lifestyle'),
  _IconOption(Icons.local_florist, 'Water Plants', 'Lifestyle'),
  _IconOption(Icons.phone_disabled, 'Digital Detox', 'Lifestyle'),
  _IconOption(Icons.volunteer_activism, 'Gratitude / Kindness', 'Lifestyle'),
];

class AddHabitModal extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const AddHabitModal({super.key, this.habitToEdit});

  static Future<bool?> show(BuildContext context, {Habit? habitToEdit}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => AddHabitModal(habitToEdit: habitToEdit),
    );
  }

  @override
  ConsumerState<AddHabitModal> createState() => _AddHabitModalState();
}

class _AddHabitModalState extends ConsumerState<AddHabitModal> {
  late TextEditingController _titleController;
  late HabitGoal _selectedGoal;
  late int _selectedIconCode;
  late List<int> _selectedDays;
  late DateTime _selectedStartDate;
  late bool _reminderEnabled;
  late TimeOfDay _pickedTime;
  bool _hasSubmittedOnce = false;

  final List<String> _weekLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    final h = widget.habitToEdit;
    _titleController = TextEditingController(text: h?.title ?? '');
    _titleController.addListener(() => setState(() {}));
    _selectedGoal = h?.goal ?? HabitGoal.build;
    _selectedIconCode = h?.iconCodePoint ?? Icons.directions_run.codePoint;
    _selectedDays = h != null
        ? List<int>.from(h.frequencyDays)
        : [1, 2, 3, 4, 5, 6, 7];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (h != null) {
      try {
        final parts = h.startDate.split('-');
        _selectedStartDate = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
      } catch (_) {
        _selectedStartDate = today;
      }

      _reminderEnabled = h.reminderTime != null;
      _pickedTime = h.reminderTime != null
          ? _parseTimeString(h.reminderTime!)
          : const TimeOfDay(hour: 7, minute: 30);
    } else {
      _selectedStartDate = today;
      _reminderEnabled = false;
      _pickedTime = const TimeOfDay(hour: 7, minute: 30);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _isTitleValid => _titleController.text.trim().isNotEmpty;
  bool get _isFrequencyValid => _selectedDays.isNotEmpty;
  bool get _canSubmit => _isTitleValid && _isFrequencyValid;

  TimeOfDay _parseTimeString(String timeString) {
    try {
      final parts = timeString.split(' ');
      final timeParts = parts[0].split(':');
      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);
      final period = parts.length > 1 ? parts[1].toUpperCase() : null;

      if (period == 'PM' && hour < 12) {
        hour += 12;
      } else if (period == 'AM' && hour == 12) {
        hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 7, minute: 30);
    }
  }

  String _formatDisplayDate(DateTime date) {
    return DateFormat('EEE, d MMM yyyy').format(date);
  }

  String _formatIsoDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _openIconPicker() async {
    final pickedCode = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: const Color(0xFF131926),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => _SystemIconPickerSheet(selectedCode: _selectedIconCode),
    );

    if (pickedCode != null) {
      setState(() => _selectedIconCode = pickedCode);
    }
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
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
      setState(() {
        _selectedStartDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickedTime,
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
      setState(() => _pickedTime = picked);
    }
  }

  void _submit() {
    setState(() => _hasSubmittedOnce = true);
    final title = _titleController.text.trim();
    if (!_canSubmit) return;

    final formattedReminder = _reminderEnabled
        ? _formatTimeOfDay(_pickedTime)
        : null;
    final startDateIso = _formatIsoDate(_selectedStartDate);
    final sortedDays = List<int>.from(_selectedDays)..sort();

    if (widget.habitToEdit != null) {
      final updated = widget.habitToEdit!.copyWith(
        title: title,
        goal: _selectedGoal,
        iconCodePoint: _selectedIconCode,
        frequencyDays: sortedDays,
        reminderTime: formattedReminder,
        startDate: startDateIso,
      );
      ref.read(habitsProvider.notifier).updateHabit(updated);
    } else {
      final newHabit = Habit(
        id: const Uuid().v4(),
        title: title,
        iconCodePoint: _selectedIconCode,
        goal: _selectedGoal,
        frequencyDays: sortedDays,
        reminderTime: formattedReminder,
        startDate: startDateIso,
      );
      ref.read(habitsProvider.notifier).addHabit(newHabit);
    }
    Navigator.of(context).pop(false);
  }

  void _delete() {
    if (widget.habitToEdit != null) {
      ref.read(habitsProvider.notifier).deleteHabit(widget.habitToEdit!.id);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final showTitleError = _hasSubmittedOnce && !_isTitleValid;
    final showFrequencyError = _hasSubmittedOnce && !_isFrequencyValid;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 24 + keyboardSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Habit' : 'Create New Habit',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1E2638),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Habit Name & Icon',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                // Pulsante icona accanto al nome dell'abitudine
                GestureDetector(
                  onTap: _openIconPicker,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF172232),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.accentGreen.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          IconData(
                            _selectedIconCode,
                            fontFamily: 'MaterialIcons',
                          ),
                          color: AppColors.accentGreen,
                          size: 26,
                        ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.accentGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              size: 9,
                              color: Color(0xFF0F131D),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Campo testo Habit Name
                Expanded(
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F1420),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: showTitleError
                            ? AppColors.deleteRedText
                            : const Color(0xFF1E2638),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _titleController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'e.g. Morning Run',
                        hintStyle: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (showTitleError) ...[
              const SizedBox(height: 6),
              const Text(
                'Habit name cannot be empty',
                style: TextStyle(
                  color: AppColors.deleteRedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),

            const Text(
              'Habit Goal',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildGoalItem(
                  HabitGoal.build,
                  'Build Habit',
                  Icons.add_circle_outline,
                ),
                const SizedBox(width: 8),
                _buildGoalItem(
                  HabitGoal.breakHabit,
                  'Break Habit',
                  Icons.remove_circle_outline,
                ),
                const SizedBox(width: 8),
                _buildGoalItem(
                  HabitGoal.trackOnly,
                  'Track Only',
                  Icons.show_chart,
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Frequency',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                final dayIndex = i + 1;
                final isSelected = _selectedDays.contains(dayIndex);
                return Flexible(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_selectedDays.contains(dayIndex)) {
                          _selectedDays.remove(dayIndex);
                        } else {
                          _selectedDays.add(dayIndex);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.accentGreen
                            : const Color(0xFF1A2234),
                      ),
                      child: Center(
                        child: Text(
                          _weekLabels[i],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? const Color(0xFF0F131D)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            if (showFrequencyError) ...[
              const SizedBox(height: 6),
              const Text(
                'Please select at least one day',
                style: TextStyle(
                  color: AppColors.deleteRedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            const SizedBox(height: 20),

            const Text(
              'Start Date',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickStartDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF171E2D),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF263147),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.accentGreen.withValues(
                                alpha: 0.14,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.calendar_month_outlined,
                              size: 18,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _formatDisplayDate(_selectedStartDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1420),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Change',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accentGreen,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 16,
                            color: AppColors.accentGreen,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF171E2D),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF263147), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _reminderEnabled
                              ? AppColors.accentGreen.withValues(alpha: 0.14)
                              : const Color(0xFF222B3D),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          size: 20,
                          color: _reminderEnabled
                              ? AppColors.accentGreen
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Daily Reminder',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _reminderEnabled,
                        activeThumbColor: AppColors.accentGreen,
                        activeTrackColor: AppColors.accentGreen.withValues(
                          alpha: 0.35,
                        ),
                        onChanged: (val) =>
                            setState(() => _reminderEnabled = val),
                      ),
                    ],
                  ),
                  if (_reminderEnabled) ...[
                    const Divider(color: Color(0xFF252F44), height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reminder Time',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: _selectReminderTime,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F1420),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.accentGreen.withValues(
                                  alpha: 0.5,
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time_filled,
                                  size: 16,
                                  color: AppColors.accentGreen,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimeOfDay(_pickedTime),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 16,
                                  color: AppColors.accentGreen,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pulsante principale nello stesso verde del calendario
            ElevatedButton(
              onPressed: _canSubmit ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                disabledBackgroundColor: AppColors.accentGreen.withValues(
                  alpha: 0.35,
                ),
                foregroundColor: const Color(0xFF0F131D),
                disabledForegroundColor: Colors.white38,
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Save Habit' : 'Create Habit',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            if (isEditing) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _delete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.deleteRedBg,
                  foregroundColor: AppColors.deleteRedText,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Delete Habit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem(HabitGoal goal, String label, IconData icon) {
    final isSelected = _selectedGoal == goal;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGoal = goal),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF162C28)
                : const Color(0xFF141A27),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.accentGreen : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 22,
                color: isSelected
                    ? AppColors.accentGreen
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Selettore moderno delle icone di sistema con ricerca e categorie
class _SystemIconPickerSheet extends StatefulWidget {
  final int selectedCode;

  const _SystemIconPickerSheet({required this.selectedCode});

  @override
  State<_SystemIconPickerSheet> createState() => _SystemIconPickerSheetState();
}

class _SystemIconPickerSheetState extends State<_SystemIconPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _query = '';

  static const List<String> _categories = [
    'All',
    'Fitness',
    'Wellness',
    'Study & Work',
    'Lifestyle',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _allSystemIcons.where((item) {
      final matchesCategory =
          _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesQuery =
          _query.isEmpty ||
          item.name.toLowerCase().contains(_query) ||
          item.category.toLowerCase().contains(_query);
      return matchesCategory && matchesQuery;
    }).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Habit Icon',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E2638),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Barra di ricerca icone
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F1420),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF222B3D)),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    icon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    hintText: 'Search icons (e.g. run, book, water, sleep)...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Categorie
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accentGreen
                                : const Color(0xFF1A2234),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected
                                  ? const Color(0xFF0F131D)
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Griglia icone
              Expanded(
                child: GridView.builder(
                  controller: scrollController,
                  itemCount: filtered.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final isSelected =
                        item.icon.codePoint == widget.selectedCode;

                    return GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pop(item.icon.codePoint),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentGreen.withValues(alpha: 0.16)
                              : const Color(0xFF171E2D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentGreen
                                : const Color(0xFF232D42),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 26,
                              color: isSelected
                                  ? AppColors.accentGreen
                                  : Colors.white,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? AppColors.accentGreen
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
