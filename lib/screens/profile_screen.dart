import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../controllers/habits_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalCompleted = ref.watch(totalCompletedHabitsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 32),
          child: Column(
            children: [
              // Card Profilo Utente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E2638), Color(0xFF171D2B)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF263044),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Avatar con anello sfumato neon ciano/viola
                    Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF5EEAD4),
                            Color(0xFF818CF8),
                            Color(0xFFA78BFA),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF818CF8).withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [Color(0xFF1D3549), Color(0xFF0B1320)],
                            center: Alignment(0, -0.2),
                            radius: 0.9,
                          ),
                        ),
                        child: ClipOval(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Luci neon di sfondo stile cyberpunk
                              Positioned(
                                left: 10,
                                top: 22,
                                child: Container(
                                  width: 18,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF2DD4BF,
                                    ).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 26,
                                child: Container(
                                  width: 16,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFF43F5E,
                                    ).withValues(alpha: 0.22),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.person,
                                size: 68,
                                color: Color(0xFFCBD5E1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'John Doe',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Card Total Habits Completed
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF171D2B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF242D40),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL HABITS COMPLETED',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$totalCompleted',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF252D40),
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryButton,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Pulsante Logout
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFF49D8A),
                  size: 20,
                ),
                label: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Color(0xFFF49D8A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
