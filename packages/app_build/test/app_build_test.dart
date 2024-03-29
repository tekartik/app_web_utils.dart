import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_app_web_build/src/app_build_base.dart';
import 'package:tekartik_app_web_build/src/test/generate_dart_project.dart';
import 'package:tekartik_app_web_build/src/webdev.dart';
import 'package:test/test.dart';

void main() {
  group('app_build', () {
    test('webdevReady', () async {
      await webdevReady(force: true, verbose: true);
    });
    test('web app', () async {
      var path = join(topDir, 'test_web_app');
      await generateDartProject(path: path, template: 'web-simple');
      await File(join(path, 'web', 'deploy.yaml')).writeAsString('''
files:
  - index.html
  - main.dart.js
  - styles.css
''');
      await webdevBuild(path);
      await buildToDeploy(path);
      await webdevClean(path);
      await webdevPubGet(path);
    }, timeout: const Timeout(Duration(minutes: 5)));
  });
}

var topDir = '.dart_tool/tekartik_app_build/test_app';
