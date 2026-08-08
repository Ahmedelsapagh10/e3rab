import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/shell/screens/e3rab_shell_screen.dart';

void main() {
  test('shell exposes the four focused destinations', () {
    expect(e3rabShellDestinations, hasLength(4));
    expect(e3rabShellDestinations.map((destination) => destination.label), [
      'الرئيسية',
      'تعلّم',
      'أعرب',
      'حسابي',
    ]);
  });
}
