import 'package:tekartik_firebase_build/firebase_deploy.dart';

/// Default deploy directory for web app.
const webAppDeployDirDefault = 'deploy';

/// Default source directory for web app.
const webAppSrcDirDefault = 'web';

/// Default web port for web app.
const webAppPortDefault = 8060;

/// Compat. to deprecate.
typedef WebAppOptions = WebAppBuildOptions;

/// Node app common options.
class WebAppBuildOptions {
  /// App packages (default to '.')
  late final String packageTop;

  /// Typically 'deploy' for a single node app
  late final String deployDir;

  /// Typically 'bin' to 'node', default to 'bin'
  late final String srcDir;

  /// Web port, default dynamic.
  final int? webPort;

  /// Constructor.
  WebAppBuildOptions(
      {String? packageTop, String? deployDir, String? srcDir, this.webPort}) {
    this.packageTop = packageTop ?? '.';
    this.deployDir = deployDir ?? webAppDeployDirDefault;
    this.srcDir = srcDir ?? webAppSrcDirDefault;
  }
}

/// Firebase web app options
class FirebaseWebAppOptions {
  /// Build options
  final WebAppBuildOptions buildOptions;

  /// Deploy options
  final FirebaseDeployOptions deployOptions;

  /// Constructor.
  FirebaseWebAppOptions(
      {required this.buildOptions, required this.deployOptions});
}
