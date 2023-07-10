import 'package:tekartik_app_web_build/app_build.dart';

import 'build.dart';

/// New builder helper
class WebAppBuilder {
  String get path => options.packageTop;
  late final WebAppOptions options;

  WebAppBuilder({WebAppOptions? options}) {
    this.options = options ?? WebAppOptions();
  }

  Future<void> clean() async {
    await webPackageClean(path, deployDirectory: options.deployDir);
  }

  Future<void> build() async {
    await webdevBuild(path, folder: options.srcDir);
  }

  Future<void> serve() async {
    await webdevServe(path, folder: options.srcDir, port: options.webPort);
  }
}
