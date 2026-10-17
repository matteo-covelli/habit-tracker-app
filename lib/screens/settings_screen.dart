import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../controllers/theme_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: AppColors.bg(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain(context),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Customize your app appearance and preferences.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textSub(context),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'APPEARANCE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  color: AppColors.textSub(context),
                ),
              ),
              const SizedBox(height: 12),

              // Card selezione Tema
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card(context),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.border(context),
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentGreen.withValues(
                              alpha: 0.14,
                            ),
                          ),
                          child: const Icon(
                            Icons.palette_outlined,
                            color: AppColors.accentGreen,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'App Theme',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textMain(context),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Choose Light, Dark, or follow System settings',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSub(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    _buildThemeOptionTile(
                      context: context,
                      ref: ref,
                      mode: ThemeMode.light,
                      currentMode: currentThemeMode,
                      title: 'Light',
                      subtitle: 'Bright and clean interface',
                      icon: Icons.light_mode_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOptionTile(
                      context: context,
                      ref: ref,
                      mode: ThemeMode.dark,
                      currentMode: currentThemeMode,
                      title: 'Dark',
                      subtitle: 'Easy on the eyes in low light',
                      icon: Icons.dark_mode_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildThemeOptionTile(
                      context: context,
                      ref: ref,
                      mode: ThemeMode.system,
                      currentMode: currentThemeMode,
                      title: 'System',
                      subtitle: 'Automatically match device settings',
                      icon: Icons.settings_brightness_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionTile({
    required BuildContext context,
    required WidgetRef ref,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = mode == currentMode;
    final isDark = AppColors.isDark(context);

    return GestureDetector(
      onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGreen.withValues(alpha: isDark ? 0.14 : 0.12)
              : AppColors.subtleBg(context),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppColors.accentGreen
                : AppColors.border(context),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accentGreen
                    : AppColors.chipUnselected(context),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF0F131D)
                    : AppColors.textSub(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textMain(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSub(context),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.accentGreen : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGreen
                      : AppColors.textSub(context).withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: Color(0xFF0F131D),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
