abstract final class ArabicSearchNormalizer {
  static final _diacritics = RegExp(
    '[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]',
  );

  static String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('\u0640', '')
        .replaceAll(_diacritics, '')
        .replaceAll(RegExp('[أإآٱ]'), 'ا')
        .replaceAll('ى', 'ي')
        .replaceAll('ؤ', 'و')
        .replaceAll('ئ', 'ي')
        .replaceAllMapped(
          RegExp('[٠-٩]'),
          (match) => '${match.group(0)!.codeUnitAt(0) - 0x660}',
        )
        .replaceAllMapped(
          RegExp('[۰-۹]'),
          (match) => '${match.group(0)!.codeUnitAt(0) - 0x6F0}',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}
