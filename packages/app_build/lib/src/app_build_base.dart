import 'package:dev_test/src/run_ci.dart' // ignore: implementation_imports
    show
        checkAndActivatePackage;
import 'package:fs_shim/fs_io.dart';
import 'package:path/path.dart';
import 'package:process_run/shell_run.dart';
import 'package:tekartik_deploy/fs/fs_deploy.dart';

/// dir is the project dir, folder is the top level folder
Future<void> webdevBuild(String dir, {String folder = 'web'}) async {
  var shell = Shell(workingDirectory: dir);
  await checkAndActivatePackage('webdev');
  await shell.run(
      'pub global run webdev build --output $folder:${join('build', folder)}');
}

/// dir is the project dir, folder is the top level folder
Future<void> webdevServe(String dir, {String folder = 'web'}) async {
  var shell = Shell(workingDirectory: dir);
  await checkAndActivatePackage('webdev');
  await shell.run(
      'pub global run webdev serve --output $folder:${join('build', folder)}');
}

/// Deploy dir default to 'deploy/web, folder is relative to the build folder
Future<void> buildToDeploy(String dir,
    {String folder = 'web', String deployDir}) async {
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
      dst: Directory(deployDir));
}

Future<void> httpDeployServe(String dir,
    {String deployDir, String folder = 'web'}) async {
  await checkAndActivatePackage('dhttpd');
  deployDir ??= join(dir, 'deploy', folder);
  var shell = Shell(workingDirectory: dir);
  print('http://localhost:8080');
  await shell.run('pub global run dhttpd --path ${shellArgument(deployDir)}');
}
