import 'dart:io';

import 'package:path/path.dart';

/// Clean node app
Future webPackageClean(String path, {String? deployDirectory}) async {
  deployDirectory ??= 'deploy';
  stdout.writeln('deleting "build"');
  try {
    await Directory('build').delete(recursive: true);
  } catch (_) {}

  var indexJs = join(deployDirectory, 'index.js');
  stdout.writeln('deleting "$indexJs"');
  try {
    await File(indexJs).delete();
  } catch (_) {}
}
