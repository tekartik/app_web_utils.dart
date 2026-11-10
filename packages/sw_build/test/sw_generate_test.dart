@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';
import 'package:tekartik_sw_build/sw_build.dart';
import 'package:test/test.dart';

void main() {
  var node = whichSync('node');
  test(
    'generated worker: offline app shell and downloadOffline',
    () async {
      var dir = join('.dart_tool', 'tekartik_sw_build', 'test', 'generate');
      await Directory(dir).create(recursive: true);
      var swPath = join(dir, 'sw.js');
      await File(swPath).writeAsString(
        generateServiceWorker(
          {'/': 'h1', 'main.dart.js': 'h2', 'other.js': 'h3'},
          ['/', 'main.dart.js'],
        ),
      );
      var result = await runExecutableArguments(node!, [
        join('test', 'data', 'sw_harness.js'),
        swPath,
      ]);
      expect(result.stdout.toString(), contains('RESULT ok'));
      expect(result.exitCode, 0);
    },
    skip: node == null ? 'node not found' : null,
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
