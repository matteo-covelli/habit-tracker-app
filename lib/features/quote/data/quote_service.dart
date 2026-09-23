import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/quote.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Accept': 'application/json'},
    ),
  );
});

final quoteServiceProvider = Provider<QuoteService>((ref) {
  return QuoteService(ref.read(dioProvider));
});

class QuoteService {
  final Dio _dio;
  static const _url = 'https://zenquotes.io/api/random';

  QuoteService(this._dio);

  Future<Quote> fetchRandomQuote() async {
    try {
      final response = await _dio.get(_url);

      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data as List<dynamic>;
        if (data.isNotEmpty) {
          return Quote.fromJson(data.first as Map<String, dynamic>);
        }
      }
      return Quote.fallback();
    } catch (_) {
      // Se il server non risponde o c'è assenza di rete, torna il fallback offline
      return Quote.fallback();
    }
  }
}
