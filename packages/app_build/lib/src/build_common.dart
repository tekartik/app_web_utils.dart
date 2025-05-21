import 'package:path/path.dart';
import 'package:process_run/stdio.dart';
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_web_publish/web_publish.dart';

import 'web_app_builder.dart';

/// Default deploy directory for web app.
const webAppDeployDirDefault = 'deploy';

/// Default source directory for web app.
const webAppSrcDirDefault = 'web';

/// Default web port for web app.
const webAppPortDefault = 8060;

/// Compat. to deprecate.
// @Deprecated('use WebAppBuildOptions')
typedef WebAppOptions = WebAppBuildOptions;

/// Local web app options.
class WebAppLocalOptions {
  /// Build options
  late final WebAppBuildOptions buildOptions;

  /// Constructor.
  WebAppLocalOptions({required WebAppBuildOptions? buildOptions}) {
    this.buildOptions = buildOptions ?? WebAppBuildOptions();
  }
}

/// Local web app builder.
class WebAppLocalBuilder
    with CommonWebAppBuilderMixin
    implements DefaultWebAppBuilder {
  /// Options
  late final WebAppLocalOptions options;

  /// Constructor.
  WebAppLocalBuilder({required this.options});
  @override
  Future<void> build() async {
    await webAppBuilder.build();
    await webAppBuildToDeploy(
      path,
      deployDir: buildOptions.deployDir,
      buildDir: join('build', buildOptions.srcDir),
    );
  }

  @override
  Future<void> deploy({FirebaseWebAppActionController? controller}) async {
    stderr.writeln('No deploy');
  }

  @override
  Future<void> serveDeployed({
    FirebaseWebAppActionController? controller,
  }) async {
    await httpDeployServe(path, deployDir: deployDir);
  }

  @override
  // TODO: implement deployOptions
  WebAppDeployOptions get deployOptions => throw UnimplementedError();

  @override
  String get target => 'local';

  @override
  // TODO: implement buildOptions
  WebAppBuildOptions get buildOptions => options.buildOptions;
}

/// Node app common options.
class WebAppBuildOptions {
  /// App packages (default to '.')
  late final String packageTop;

  /// Default to 'deploy'.
  late final String deployDir;

  /// Default to web.
  late final String srcDir;

  /// Web port, default dynamic.
  final int? webPort;

  /// Constructor.
  WebAppBuildOptions({
    String? packageTop,
    String? deployDir,
    String? srcDir,
    this.webPort,
  }) {
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
  FirebaseWebAppOptions({
    required this.buildOptions,
    required this.deployOptions,
  });
}
