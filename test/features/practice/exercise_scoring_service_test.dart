import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/practice/domain/exercise_scoring_service.dart';

void main() {
  const service = ExerciseScoringService();

  test('applies the locked mastery weights', () {
    expect(
      service
          .score(isCorrect: true, hintUsed: false, hasPriorError: false)
          .weight,
      1,
    );
    expect(
      service
          .score(isCorrect: true, hintUsed: true, hasPriorError: false)
          .weight,
      .7,
    );
    expect(
      service
          .score(isCorrect: true, hintUsed: false, hasPriorError: true)
          .weight,
      .5,
    );
    final revealed = service.score(
      isCorrect: true,
      hintUsed: true,
      hasPriorError: false,
      revealed: true,
    );
    expect(revealed.weight, 0);
    expect(revealed.isCorrect, isFalse);
  });
}
