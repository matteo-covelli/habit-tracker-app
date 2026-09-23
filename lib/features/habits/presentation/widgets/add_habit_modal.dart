import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/habit.dart';
import '../controllers/habits_controller.dart';

class AddHabitModal extends ConsumerStatefulWidget {
  final Habit? habitToEdit;

  const AddHabitModal({super.key, this.habitToEdit});

  static Future<void> show(BuildContext context, {Habit? habitToEdit}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
  bool _reminderEnabled = true;
  TimeOfDay _pickedTime = const TimeOfDay(hour: 7, minute: 30);
  bool _hasSubmittedOnce = false;

  final List<int> _iconChoices = [
    Icons.directions_run.codePoint,
    Icons.menu_book.codePoint,
    Icons.water_drop.codePoint,
    Icons.self_improvement.codePoint,
    Icons.nightlight_round.codePoint,
    Icons.alarm.codePoint,
    Icons.favorite.codePoint,
    Icons.code.codePoint,
  ];

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
    _selectedIconCode = h?.iconCodePoint ?? _iconChoices.first;
    _selectedDays = h != null
        ? List.from(h.frequencyDays)
        : [1, 2, 3, 4, 5, 6, 7];
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool get _isTitleValid => _titleController.text.trim().isNotEmpty;

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  void _selectReminderTime() {
    TimeOfDay tempPicked = _pickedTime;
    final now = DateTime.now();
    final initialDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _pickedTime.hour,
      _pickedTime.minute,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E2638),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext modalContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () => Navigator.of(modalContext).pop(),
                    ),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: const Text(
                        'Done',
                        style: TextStyle(
                          color: AppColors.primaryButton,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _pickedTime = tempPicked);
                        Navigator.of(modalContext).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2E394E), height: 1),
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      pickerTextStyle: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    use24hFormat: false,
                    initialDateTime: initialDateTime,
                    onDateTimeChanged: (DateTime newDateTime) {
                      tempPicked = TimeOfDay(
                        hour: newDateTime.hour,
                        minute: newDateTime.minute,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() {
    setState(() => _hasSubmittedOnce = true);
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final formattedReminder = _reminderEnabled
        ? _formatTimeOfDay(_pickedTime)
        : null;

    if (widget.habitToEdit != null) {
      final updated = widget.habitToEdit!.copyWith(
        title: title,
        goal: _selectedGoal,
        iconCodePoint: _selectedIconCode,
        frequencyDays: _selectedDays,
        reminderTime: formattedReminder,
      );
      ref.read(habitsProvider.notifier).updateHabit(updated);
    } else {
      final newHabit = Habit(
        id: const Uuid().v4(),
        title: title,
        iconCodePoint: _selectedIconCode,
        goal: _selectedGoal,
        frequencyDays: _selectedDays,
        reminderTime: formattedReminder,
      );
      ref.read(habitsProvider.notifier).addHabit(newHabit);
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    if (widget.habitToEdit != null) {
      ref.read(habitsProvider.notifier).deleteHabit(widget.habitToEdit!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habitToEdit != null;
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    final showError = _hasSubmittedOnce && !_isTitleValid;

    return SingleChildScrollView(
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
            'Habit Name',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1420),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: showError ? AppColors.deleteRedText : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: TextField(
              controller: _titleController,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                icon: Icon(Icons.edit_note, color: AppColors.textSecondary),
                border: InputBorder.none,
                hintText: 'e.g. Morning Run',
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
          ),
          if (showError) ...[
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
            'Choose Icon',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171E2D),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _iconChoices.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 2.1,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final code = _iconChoices[index];
                final isSelected = code == _selectedIconCode;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIconCode = code),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF333E5A)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      IconData(code, fontFamily: 'MaterialIcons'),
                      color: isSelected
                          ? AppColors.primaryButton
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
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
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedDays.remove(dayIndex);
                    } else {
                      _selectedDays.add(dayIndex);
                    }
                  });
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? const Color(0xFF6B7FD7)
                        : const Color(0xFF1A2234),
                  ),
                  child: Center(
                    child: Text(
                      _weekLabels[i],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF171E2D),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF222B3D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 20,
                        color: Colors.white,
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
                      activeColor: AppColors.primaryButton,
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
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2D384E),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTimeOfDay(_pickedTime),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
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

          ElevatedButton(
            onPressed: _isTitleValid ? _submit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryButton,
              disabledBackgroundColor: AppColors.primaryButton.withOpacity(
                0.35,
              ),
              foregroundColor: AppColors.primaryButtonText,
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
                    fontWeight: FontWeight.bold,
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
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
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
                ? const Color(0xFF222C42)
                : const Color(0xFF141A27),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? const Color(0xFF4C5D8A) : Colors.transparent,
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
                    ? AppColors.primaryButton
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
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
