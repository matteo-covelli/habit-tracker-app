import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../controllers/quote_controller.dart';

class QuoteCard extends ConsumerWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(quoteNotifierProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2333),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: quoteAsync.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : const Icon(
                      Icons.refresh,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
              onPressed: quoteAsync.isLoading
                  ? null
                  : () =>
                        ref.read(quoteNotifierProvider.notifier).refreshQuote(),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
                child: const Icon(
                  Icons.format_quote,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              quoteAsync.when(
                data: (quote) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"${quote.text}"',
                      style: const TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${quote.author.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFF131926),
                    color: AppColors.primaryButton,
                    minHeight: 2,
                  ),
                ),
                error: (_, __) => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"We are what we repeatedly do. Excellence, then, is not an act, but a habit."',
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '— ARISTOTLE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
