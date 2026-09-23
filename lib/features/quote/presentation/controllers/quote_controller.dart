import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/quote_service.dart';
import '../../domain/quote.dart';

final quoteNotifierProvider = AsyncNotifierProvider<QuoteNotifier, Quote>(
  QuoteNotifier.new,
);

class QuoteNotifier extends AsyncNotifier<Quote> {
  @override
  Future<Quote> build() async {
    return ref.read(quoteServiceProvider).fetchRandomQuote();
  }

  Future<void> refreshQuote() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(quoteServiceProvider).fetchRandomQuote(),
    );
  }
}
