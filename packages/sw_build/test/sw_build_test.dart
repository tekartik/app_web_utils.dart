@TestOn('vm')
library tekartik_sw_build_test;

import 'package:tekartik_sw_build/src/sw_build.dart';
import 'package:test/test.dart';

void main() {
  group('sw_build', () {
    test('print', () async {
      await swPackageBuild('.', directory: 'example');
    });
  });
}

//var topDir = '.dart_tool/tekartik_app_build/test_app';
