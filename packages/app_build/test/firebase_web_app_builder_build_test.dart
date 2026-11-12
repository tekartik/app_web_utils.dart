@TestOn('vm')
library;

import 'dart:io';

import 'package:path/path.dart';
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_app_web_build/src/test/generate_dart_project.dart';
import 'package:test/test.dart';

bool _exists(String path) =>
    FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;

void main() {
  test('firebase build keeps the hosting config', () async {
    var pkg = absolute(
      join('.dart_tool', 'tekartik_app_build', 'test_firebase_build'),
    );
    await generateDartProject(path: pkg, template: 'web-simple');
    await File(join(pkg, 'web', 'deploy.yaml')).writeAsString('''
files:
  - index.html
  - main.dart.js
  - styles.css
''');
    var hostingDir = join('deploy', 'firebase', 'hosting');
    await Directory(join(pkg, hostingDir)).create(recursive: true);
    await File(join(pkg, hostingDir, 'firebase.json')).writeAsString('{}');
    await File(join(pkg, hostingDir, '.firebaserc')).writeAsString('{}');

    await FirebaseWebAppBuilder(
      options: FirebaseWebAppOptions(
        buildOptions: WebAppBuildOptions(
          packageTop: pkg,
          deployDir: hostingDir,
        ),
        deployOptions: FirebaseDeployOptions(
          projectId: 'demo-test',
          hostingId: 'demo-test',
          target: 'test',
        ),
      ),
    ).build();
    // The hosting config is kept, the build goes to public/ only.
    expect(_exists(join(pkg, hostingDir, 'firebase.json')), isTrue);
    expect(_exists(join(pkg, hostingDir, '.firebaserc')), isTrue);
    expect(_exists(join(pkg, hostingDir, 'public', 'index.html')), isTrue);
    expect(_exists(join(pkg, hostingDir, 'public', 'main.dart.js')), isTrue);
    expect(_exists(join(pkg, hostingDir, 'index.html')), isFalse);
    await Directory(pkg).delete(recursive: true);
  }, timeout: const Timeout(Duration(minutes: 5)));
}
