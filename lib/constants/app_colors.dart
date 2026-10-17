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
  static Color getHabitIconColor(int codePoint) {
    if (codePoint == Icons.directions_run.codePoint) {
      return const Color(0xFF10B981);
    }
    if (codePoint == Icons.self_improvement.codePoint) {
      return const Color(0xFFA5B4FC);
    }
    if (codePoint == Icons.menu_book.codePoint) {
      return const Color(0xFFE2E8F0);
    }
    if (codePoint == Icons.water_drop.codePoint) {
      return const Color(0xFF34D399);
    }
    if (codePoint == Icons.code.codePoint) {
      return const Color(0xFFA5B4FC);
    }
    if (codePoint == Icons.nightlight_round.codePoint) {
      return const Color(0xFFFBBF24);
    }
    if (codePoint == Icons.alarm.codePoint) {
      return const Color(0xFFF97316);
    }
    return const Color(0xFFF59E0B);
  }

  /// Restituisce il colore di sfondo del cerchio icona
  static Color getHabitIconBgColor(int codePoint) {
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
}
