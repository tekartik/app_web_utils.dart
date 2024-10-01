import 'package:path/path.dart';
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_web_publish/surge_web_publish.dart';
import 'package:tekartik_web_publish/web_publish.dart';
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

/// Surge web app options
class SurgeWebAppOptions {
  /// Build options
  final WebAppBuildOptions buildOptions;

  /// Deploy options
  final SurgeWebAppDeployOptions deployOptions;

  /// Constructor.
  SurgeWebAppOptions({required this.deployOptions, required this.buildOptions});
}

/// Surge web app builder
class SurgeWebAppBuilder
    with CommonWebAppBuilderMixin
    implements CommonWebAppBuilder {
  /// Options
  final SurgeWebAppOptions options;

  late final _surgeWebAppDeployer =
      SurgeWebAppDeployer(options: options.deployOptions, path: deployDir);

  /// Constructor.
  SurgeWebAppBuilder({required this.options});
  @override
  Future<void> build() async {
    await webAppBuilder.build();
    await webAppBuildToDeploy(path,
        deployDir: options.buildOptions.deployDir,
        buildDir: join('build', options.buildOptions.srcDir));
  }

  @override
  Future<void> deploy({FirebaseWebAppActionController? controller}) async {
    await _surgeWebAppDeployer.deploy();
  }

  @override
  Future<void> serveDeployed(
      {FirebaseWebAppActionController? controller}) async {
    await httpDeployServe(path, deployDir: deployDir);
  }

  @override
  String get target => options.deployOptions.domain;

  @override
  WebAppDeployOptions get deployOptions => options.deployOptions;

  @override
  WebAppBuildOptions get buildOptions => options.buildOptions;
}

/// Common web app builder mixin
mixin CommonWebAppBuilderMixin implements CommonWebAppBuilder {
  @override
  late final webAppBuilder = WebAppBuilder(options: buildOptions);

  /// Path to the package top
  String get path => buildOptions.packageTop;

  /// Deploy dir
  String get deployDir => buildOptions.deployDir;

  /// Clean
  @override
  Future<void> clean() async {
    await webAppBuilder.clean();
  }

  /// Serve
  @override
  Future<void> serve() async {
    await webAppBuilder.serve();
  }

  /// Build and serve
  Future<void> buildAndServe() async {
    await build();
    await serveDeployed();
  }

  /// Build and serve
  Future<void> buildAndDeploy() async {
    await build();
    await deploy();
  }
}

/// Common web app builder
abstract class CommonWebAppBuilder {
  /// Web app builder.
  WebAppBuilder get webAppBuilder;

  /// Build options
  WebAppBuildOptions get buildOptions;

  /// Deploy options
  WebAppDeployOptions get deployOptions;

  /// Target (per builder, target in firebase, domain in surge)
  String get target;

  /// Clean.
  Future<void> clean();

  /// Build
  Future<void> build();

  /// Serve
  Future<void> serve();

  /// Deploy
  Future<void> deploy({FirebaseWebAppActionController? controller});

  /// Server content that has been deployed.
  Future<void> serveDeployed({FirebaseWebAppActionController? controller});
}

/// Firebase web app builder
class FirebaseWebAppBuilder
    with CommonWebAppBuilderMixin
    implements CommonWebAppBuilder {
  /// Options
  final FirebaseWebAppOptions options;

  @override
  WebAppDeployOptions get deployOptions => options.deployOptions;

  /// Constructor.
  FirebaseWebAppBuilder({required this.options});

  /// Build target.
  @override
  String get target => options.deployOptions.target;

  /// Build
  @override
  Future<void> build() async {
    await webAppBuilder.build();
    await firebaseWebAppBuildToDeploy(path,
        deployDir: options.buildOptions.deployDir);
  }

  /// Deploy
  @override
  Future<void> deploy({FirebaseWebAppActionController? controller}) async {
    await firebaseWebAppDeploy(path, options.deployOptions,
        deployDir: options.buildOptions.deployDir, controller: controller);
  }

  /// Deploy
  @override
  Future<void> serveDeployed(
      {FirebaseWebAppActionController? controller}) async {
    await firebaseWebAppServe(path, options.deployOptions,
        deployDir: options.buildOptions.deployDir, controller: controller);
  }

  @override
  WebAppBuildOptions get buildOptions => options.buildOptions;
}
