import 'package:tekartik_common_utils/env_utils.dart';
import 'package:test/test.dart';

void main() {
  test('kDartIsWeb', () {
    // dart:io is only available outside the web (vm)
    expect(kDartIsWeb, !const bool.fromEnvironment('dart.library.io'));
  });
}
