import 'package:tekartik_app_web_build/app_build.dart';

import 'build.dart';

/// New builder helper
class WebAppBuilder {
  /// Path to the package top
  String get path => options.packageTop;

  /// Options
  late final WebAppOptions options;

  /// Constructor.
  WebAppBuilder({WebAppOptions? options}) {
    this.options = options ?? WebAppOptions();
  }

  /// Clean
  Future<void> clean() async {
    await webPackageClean(path, deployDirectory: options.deployDir);
  }

  /// Build
  Future<void> build() async {
    await webdevBuild(path, folder: options.srcDir);
  }

  /// Serve
  Future<void> serve() async {
    await webdevServe(path, folder: options.srcDir, port: options.webPort);
  }
}

/// Firebase web app builder
class FirebaseWebAppBuilder {
  /// Path to the package top
  String get path => options.buildOptions.packageTop;

  /// Options
  final FirebaseWebAppOptions options;

  /// Constructor.
  FirebaseWebAppBuilder({required this.options});

  /// Build target.
  String get target => options.deployOptions.target;

  /// Clean
  Future<void> clean() async {
    await webPackageClean(path,
        deployDirectory: options.buildOptions.deployDir);
  }

  /// Build
  Future<void> build() async {
    await webdevBuild(path, folder: options.buildOptions.srcDir);
    await firebaseWebAppBuildToDeploy(path,
        deployDir: options.buildOptions.deployDir);
  }

  /// Serve
  Future<void> serve() async {
    await webdevServe(path,
        folder: options.buildOptions.srcDir,
        port: options.buildOptions.webPort);
  }

  /// Deploy
  Future<void> deploy({FirebaseWebAppActionController? controller}) async {
    await firebaseWebAppDeploy(path, options.deployOptions,
        deployDir: options.buildOptions.deployDir, controller: controller);
  }

  /// Deploy
  Future<void> serveDeployed(
      {FirebaseWebAppActionController? controller}) async {
    await firebaseWebAppServe(path, options.deployOptions,
        deployDir: options.buildOptions.deployDir, controller: controller);
  }
}
