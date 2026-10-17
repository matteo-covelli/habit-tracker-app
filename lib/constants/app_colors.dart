import 'package:flutter/material.dart';

class AppColors {
  // Sfondi e Superfici
  static const Color background = Color(0xFF0F131D);
  static const Color surface = Color(0xFF19202E);
  static const Color surfaceLight = Color(0xFF222B3D);
  static const Color cardBorder = Color(0xFF283247);

  // Colori Accento Principali
  static const Color primaryButton = Color(0xFFA5B4FC); // Lilla / Light Indigo
  static const Color primaryButtonText = Color(0xFF0F131D);
  static const Color accentGreen = Color(0xFF34D399); // Check verde smeraldo
  static const Color accentOrange = Color(0xFFF59E0B); // Fiamma streak

  // Cerchietti icone abitudini
  static const Color iconMeditation = Color(0xFF10B981);
  static const Color iconWater = Color(0xFF818CF8);
  static const Color iconCircleBg = Color(0xFF232D40);

  // Tipografia
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E9BB3);
  static const Color textMuted = Color(0xFF5A667E);

  // Stati e Danger
  static const Color deleteRedBg = Color(0xFF2D1B22);
  static const Color deleteRedText = Color(0xFFF87171);

  /// Restituisce il colore principale associato all'icona dell'abitudine
  static Color getHabitIconColor(int codePoint, {bool isDark = true}) {
    if (codePoint == Icons.directions_run.codePoint) {
      return const Color(0xFF10B981);
    }
    if (codePoint == Icons.self_improvement.codePoint) {
      return isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1);
    }
    if (codePoint == Icons.menu_book.codePoint) {
      return isDark ? const Color(0xFFE2E8F0) : const Color(0xFF475569);
    }
    if (codePoint == Icons.water_drop.codePoint) {
      return isDark ? const Color(0xFF34D399) : const Color(0xFF0EA5E9);
    }
    if (codePoint == Icons.code.codePoint) {
      return isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1);
    }
    if (codePoint == Icons.nightlight_round.codePoint) {
      return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);
    }
    if (codePoint == Icons.alarm.codePoint) {
      return const Color(0xFFF97316);
    }
    return const Color(0xFFF59E0B);
  }

  /// Restituisce il colore di sfondo del cerchio icona
  static Color getHabitIconBgColor(int codePoint, {bool isDark = true}) {
    if (!isDark) {
      return getHabitIconColor(
        codePoint,
        isDark: false,
      ).withValues(alpha: 0.14);
    }
    if (codePoint == Icons.directions_run.codePoint) {
      return const Color(0xFF11352F);
    }
    if (codePoint == Icons.self_improvement.codePoint) {
      return const Color(0xFF252B48);
    }
    if (codePoint == Icons.menu_book.codePoint) {
      return const Color(0xFF262F3F);
    }
    if (codePoint == Icons.water_drop.codePoint) {
      return const Color(0xFF153330);
    }
    if (codePoint == Icons.code.codePoint) {
      return const Color(0xFF232946);
    }
    if (codePoint == Icons.nightlight_round.codePoint) {
      return const Color(0xFF332B19);
    }
    if (codePoint == Icons.alarm.codePoint) {
      return const Color(0xFF35231B);
    }
    return const Color(0xFF35281A);
  }

  // --- Helper dinamici per Tema Chiaro / Scuro ---

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDark(context) ? background : const Color(0xFFF4F6FB);

  static Color card(BuildContext context) =>
      isDark(context) ? const Color(0xFF151C28) : Colors.white;

  static Color surfaceCard(BuildContext context) =>
      isDark(context) ? surface : Colors.white;

  static Color elevatedSurface(BuildContext context) =>
      isDark(context) ? const Color(0xFF1B2333) : Colors.white;

  static Color modalBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF131926) : const Color(0xFFF8FAFC);

  static Color subtleBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF0E131D) : const Color(0xFFEEF2F8);

  static Color chipUnselected(BuildContext context) =>
      isDark(context) ? const Color(0xFF1A2234) : const Color(0xFFE8EEF6);

  static Color cellUnmarked(BuildContext context) =>
      isDark(context) ? const Color(0xFF232B3C) : const Color(0xFFE2E8F0);

  static Color border(BuildContext context) =>
      isDark(context) ? const Color(0xFF212B3E) : const Color(0xFFE2E8F0);

  static Color textMain(BuildContext context) =>
      isDark(context) ? textPrimary : const Color(0xFF0F172A);

  static Color textSub(BuildContext context) =>
      isDark(context) ? textSecondary : const Color(0xFF64748B);

  static Color accentPrimary(BuildContext context) =>
      isDark(context) ? primaryButton : const Color(0xFF6366F1);

  static Color accentPrimaryFg(BuildContext context) =>
      isDark(context) ? primaryButtonText : Colors.white;

  static Color streakBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF33261B) : const Color(0xFFFFF7ED);

  static Color streakBorder(BuildContext context) =>
      isDark(context) ? const Color(0xFF4D3822) : const Color(0xFFFED7AA);

  static Color streakText(BuildContext context) =>
      isDark(context) ? accentOrange : const Color(0xFFD97706);

  static Widget pickerTheme(BuildContext context, Widget? child) {
    final dark = isDark(context);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: dark
            ? const ColorScheme.dark(
                primary: accentGreen,
                onPrimary: Color(0xFF0F131D),
                surface: surface,
                onSurface: textPrimary,
              )
            : const ColorScheme.light(
                primary: Color(0xFF10B981),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF0F172A),
              ),
      ),
      child: child!,
    );
  }
}
