import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/core/search/arabic_search_normalizer.dart';
import 'package:new_strucuture/core/search/arabic_search_ranker.dart';

void main() {
  test('normalizer removes diacritics and folds Alef and Arabic digits', () {
    expect(ArabicSearchNormalizer.normalize('إِعْرَاب ١۲'), 'اعراب 12');
  });

  test('normalizer does not merge teh marbuta with heh', () {
    expect(
      ArabicSearchNormalizer.normalize('مدرسة'),
      isNot(ArabicSearchNormalizer.normalize('مدرسه')),
    );
  });

  test('ranker prioritizes title then keywords then body', () {
    final titleScore = ArabicSearchRanker.score(
      query: 'المبتدأ',
      title: 'المبتدأ والخبر',
      keywords: '',
      body: '',
    );
    final keywordScore = ArabicSearchRanker.score(
      query: 'المبتدأ',
      title: 'قاعدة',
      keywords: 'المبتدأ',
      body: '',
    );
    final bodyScore = ArabicSearchRanker.score(
      query: 'المبتدأ',
      title: 'قاعدة',
      keywords: '',
      body: 'المبتدأ مرفوع',
    );

    expect(titleScore, greaterThan(keywordScore));
    expect(keywordScore, greaterThan(bodyScore));
  });
}
