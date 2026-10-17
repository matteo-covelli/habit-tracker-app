import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../controllers/quote_controller.dart';

class QuoteCard extends ConsumerWidget {
  const QuoteCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteAsync = ref.watch(quoteNotifierProvider);
    final isDark = AppColors.isDark(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.elevatedSurface(context),
        borderRadius: BorderRadius.circular(28),
        border: isDark
            ? null
            : Border.all(color: AppColors.border(context), width: 1),
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
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: quoteAsync.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textSub(context),
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      size: 20,
                      color: AppColors.textSub(context),
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
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.subtleBg(context),
                ),
                child: Icon(
                  Icons.format_quote,
                  color: AppColors.textSub(context),
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
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppColors.textMain(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ${quote.author.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
                      ),
                    ),
                  ],
                ),
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: LinearProgressIndicator(
                    backgroundColor: AppColors.subtleBg(context),
                    color: AppColors.accentPrimary(context),
                    minHeight: 2,
                  ),
                ),
                error: (_, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '"We are what we repeatedly do. Excellence, then, is not an act, but a habit."',
                      style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: AppColors.textMain(context),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '— ARISTOTLE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: AppColors.textSub(context),
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
