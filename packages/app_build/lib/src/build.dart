import 'dart:io';

import 'package:path/path.dart';

import 'build_common.dart';

/// Clean a web app package at [path]: deletes its `build` folder and the
/// folder the build is copied to, [deployDirectory] (default `deploy`,
/// relative to [path]).
///
/// The deploy folder is only deleted when it is inside [path].
Future<void> webPackageClean(String path, {String? deployDirectory}) async {
  deployDirectory ??= webAppDeployDirDefault;
  await _deleteDirectory(join(path, 'build'));

  var deployDir = isAbsolute(deployDirectory)
      ? deployDirectory
      : join(path, deployDirectory);
  if (isWithin(normalize(absolute(path)), normalize(absolute(deployDir)))) {
    await _deleteDirectory(deployDir);
  } else {
    stdout.writeln('not deleting "$deployDir", outside "$path"');
  }
}

Future<void> _deleteDirectory(String path) async {
  stdout.writeln('deleting "$path"');
  try {
    await Directory(path).delete(recursive: true);
  } catch (_) {}
}
