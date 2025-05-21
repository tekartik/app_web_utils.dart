import 'dart:io';

import 'package:path/path.dart';
import 'package:process_run/shell.dart';

import 'import.dart';

Future<void> packageBuildWebWorker() async {}

/// Build for node, adding preamble for generated js files.
///
Future<void> swPackageBuild(String path, {String directory = 'sw'}) async {
  var shell = Shell(workingDirectory: path);
  await shell.run(
    'dart run build_runner build'
    ' --output=build/ $directory',
  );

  var files =
      await Directory(
        join(path, 'build', directory),
      ).list().where((event) => event.path.endsWith('dart.js')).toList();
  print(files);
}
