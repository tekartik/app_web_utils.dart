@TestOn('vm')
library;

import 'dart:io';
import 'dart:isolate';

import 'package:path/path.dart';
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:test/test.dart';

var _topDir = absolute(join('.dart_tool', 'tekartik_app_build', 'test_clean'));

/// Create [path] with a file in it.
Future<void> _createDirWithFile(String path, [String name = 'file.txt']) async {
  await Directory(path).create(recursive: true);
  await File(join(path, name)).writeAsString('test');
}

Future<String> _cleanDir(String name) async {
  var dir = join(_topDir, name);
  try {
    await Directory(dir).delete(recursive: true);
  } catch (_) {}
  await Directory(dir).create(recursive: true);
  return dir;
}

bool _exists(String path) =>
    FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;

void main() {
  group('clean', () {
    test('package build and deploy', () async {
      var pkg = await _cleanDir('pkg');
      await _createDirWithFile(join(pkg, 'build', 'web'));
      await _createDirWithFile(join(pkg, 'deploy'), 'index.html');
      await _createDirWithFile(join(pkg, 'web'), 'index.html');

      await WebAppBuilder(options: WebAppBuildOptions(packageTop: pkg)).clean();
      expect(_exists(join(pkg, 'build')), isFalse);
      expect(_exists(join(pkg, 'deploy')), isFalse);
      expect(_exists(join(pkg, 'web', 'index.html')), isTrue);
    });

    test('custom deploy dir', () async {
      var pkg = await _cleanDir('pkg_custom');
      await _createDirWithFile(join(pkg, 'deploy', 'other'));
      await _createDirWithFile(join(pkg, 'deploy', 'surge'), 'index.html');

      await WebAppBuilder(
        options: WebAppBuildOptions(
          packageTop: pkg,
          deployDir: join('deploy', 'surge'),
        ),
      ).clean();
      expect(_exists(join(pkg, 'deploy', 'surge')), isFalse);
      expect(_exists(join(pkg, 'deploy', 'other', 'file.txt')), isTrue);
    });

    test('deploy dir outside the package is kept', () async {
      var pkg = await _cleanDir('pkg_outside');
      var outside = await _cleanDir('outside');
      await _createDirWithFile(outside);

      await WebAppBuilder(
        options: WebAppBuildOptions(packageTop: pkg, deployDir: outside),
      ).clean();
      expect(_exists(join(outside, 'file.txt')), isTrue);
    });

    test('firebase keeps the hosting config', () async {
      var pkg = await _cleanDir('pkg_firebase');
      var hostingDir = join('deploy', 'firebase', 'hosting');
      await _createDirWithFile(join(pkg, 'build', 'web'));
      await _createDirWithFile(join(pkg, hostingDir), 'firebase.json');
      await _createDirWithFile(join(pkg, hostingDir, 'public'), 'index.html');

      await FirebaseWebAppBuilder(
        options: FirebaseWebAppOptions(
          buildOptions: WebAppBuildOptions(
            packageTop: pkg,
            deployDir: hostingDir,
          ),
          deployOptions: FirebaseDeployOptions(
            projectId: 'test_project',
            hostingId: 'test_hosting',
            target: 'test_target',
          ),
        ),
      ).clean();
      expect(_exists(join(pkg, 'build')), isFalse);
      expect(_exists(join(pkg, hostingDir, 'public')), isFalse);
      expect(_exists(join(pkg, hostingDir, 'firebase.json')), isTrue);
    });

    test('run from another directory', () async {
      // Clean ran from [cwd]: the package is cleaned, not the current
      // directory.
      var pkg = await _cleanDir('pkg_cwd');
      var cwd = await _cleanDir('cwd');
      await _createDirWithFile(join(pkg, 'build', 'web'));
      await _createDirWithFile(join(cwd, 'build', 'web'));
      await _createDirWithFile(join(cwd, 'deploy'), 'index.js');
      var script = join(cwd, 'clean.dart');
      await File(script).writeAsString('''
import 'package:tekartik_app_web_build/app_build.dart';

Future<void> main(List<String> args) async {
  await WebAppBuilder(options: WebAppBuildOptions(packageTop: args.first))
      .clean();
}
''');
      var packageConfig = (await Isolate.packageConfig)!.toFilePath();
      var result = await Process.run(Platform.resolvedExecutable, [
        '--packages=$packageConfig',
        script,
        pkg,
      ], workingDirectory: cwd);
      expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
      expect(_exists(join(pkg, 'build')), isFalse);
      expect(_exists(join(cwd, 'build', 'web', 'file.txt')), isTrue);
      expect(_exists(join(cwd, 'deploy', 'index.js')), isTrue);
    });
  });
}
