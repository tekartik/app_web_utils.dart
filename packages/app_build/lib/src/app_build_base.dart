import 'package:fs_shim/fs_io.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';

import 'package:tekartik_app_web_build/src/webdev.dart';
import 'package:tekartik_deploy/fs/fs_deploy.dart';

import 'build_common.dart';
import 'import.dart';

/// dir is the project dir, folder is the top level folder, default to 'web';
Future<void> webdevBuild(
  String dir, {
  String? folder = webAppSrcDirDefault,
}) async {
  folder ??= 'web';
  await webdevReady();
  var shell = Shell(workingDirectory: dir);
  await shell.run('webdev build --output $folder:${join('build', folder)}');
}

/// dir is the project dir, folder is the top level folder
Future<void> webdevServe(
  String dir, {
  String folder = webAppSrcDirDefault,
  int? port,
}) async {
  await webdevReady();
  var shell = Shell(workingDirectory: dir);
  await shell.run(
    'webdev serve $folder${port == null ? '' : ':$port'} --auto refresh',
  );
}

/// path is the project dir
Future<void> webdevPubGet(String path) async {
  var shell = Shell(workingDirectory: path);
  await shell.run('dart pub get');
}

/// path is the project dir
Future<void> webdevPubUpgrade(String path) async {
  var shell = Shell(workingDirectory: path);
  await shell.run('dart pub upgrade');
}

/// dir is the project dir, folder is the top level folder
Future<void> webdevClean(String path, {String folder = 'web'}) async {
  try {
    var dir = 'build';
    print('Deleting \'$dir\' folder');
    await Directory(join(path, dir)).delete(recursive: true);
  } catch (_) {}
}

/// Deploy dir default to 'deploy/web, folder is relative to the build folder
Future<void> buildToDeploy(
  String dir, {
  String folder = 'web',
  String? deployDir,
}) async {
  var buildFolder = join(dir, 'build', folder);
  deployDir ??= join(dir, 'deploy', folder);

  var deployFile = File(join(buildFolder, 'deploy.yaml'));
  if (!await deployFile.exists()) {
    throw StateError('Missing deploy.yaml file ($deployFile)');
  }
  await fsDeploy(
    options: FsDeployOptions()..noSymLink = true,
    yaml: deployFile,
    src: Directory(buildFolder),
    dst: Directory(deployDir),
  );
}

/// Serve release build using dhttpd
Future<void> httpDeployServe(
  String dir, {
  String? deployDir,
  String folder = 'web',
}) async {
  await checkAndActivatePackage('dhttpd');
  deployDir ??= join(dir, 'deploy', folder);
  var shell = Shell(workingDirectory: dir);
  print('http://localhost:8080');
  await shell.run(
    'dart pub global run dhttpd --path ${shellArgument(deployDir)}',
  );
}
