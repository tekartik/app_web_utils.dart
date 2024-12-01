import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

void main() {
  test('supported', () {
    if (kDartIsWeb) {
      expect(kDartIsWeb, isTrue);
    } else {
      expect(kDartIsWeb, isFalse);
    }
  });
}
