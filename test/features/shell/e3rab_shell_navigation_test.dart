import 'package:flutter_test/flutter_test.dart';
import 'package:new_strucuture/features/shell/screens/e3rab_shell_screen.dart';

void main() {
  test('shell exposes only the three simple destinations', () {
    expect(e3rabShellDestinations, hasLength(3));
    expect(e3rabShellDestinations.map((destination) => destination.label), [
      'الرئيسية',
      'الدروس',
      'حسابي',
    ]);
  });
}
