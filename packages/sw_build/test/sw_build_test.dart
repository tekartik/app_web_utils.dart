@TestOn('vm')
library;

import 'package:tekartik_sw_build/src/sw_build.dart';
import 'package:test/test.dart';

void main() {
  group('sw_build', () {
    test('print', () async {
      await swPackageBuild('.', directory: 'example');
    }, timeout: Timeout(Duration(minutes: 5)));
  });
}

//var topDir = '.dart_tool/tekartik_app_build/test_app';
