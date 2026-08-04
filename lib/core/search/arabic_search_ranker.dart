import 'arabic_search_normalizer.dart';

abstract final class ArabicSearchRanker {
  static int score({
    required String query,
    required String title,
    required String keywords,
    required String body,
  }) {
    final key = ArabicSearchNormalizer.normalize(query);
    if (key.isEmpty) return 0;
    final normalizedTitle = ArabicSearchNormalizer.normalize(title);
    final normalizedKeywords = ArabicSearchNormalizer.normalize(keywords);
    final normalizedBody = ArabicSearchNormalizer.normalize(body);
    final searchable = '$normalizedTitle $normalizedKeywords $normalizedBody';
    final tokens = key.split(' ').where((token) => token.isNotEmpty);
    if (!tokens.every(searchable.contains)) return 0;

    var score = 0;
    if (normalizedTitle == key) {
      score += 120;
    } else if (normalizedTitle.startsWith(key)) {
      score += 90;
    } else if (normalizedTitle.contains(key)) {
      score += 70;
    }
    if (normalizedKeywords.contains(key)) score += 45;
    if (normalizedBody.contains(key)) score += 25;
    for (final token in tokens) {
      if (normalizedTitle.contains(token)) score += 12;
      if (normalizedKeywords.contains(token)) score += 8;
      if (normalizedBody.contains(token)) score += 3;
    }
    return score;
  }
}
