class Quote {
  final String text;
  final String author;

  const Quote({required this.text, required this.author});

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['q'] as String? ?? 'Keep pushing forward every single day.',
      author: json['a'] as String? ?? 'Unknown',
    );
  }

  factory Quote.fallback() {
    return const Quote(
      text:
          'We are what we repeatedly do. Excellence, then, is not an act, but a habit.',
      author: 'Aristotle',
    );
  }
}
