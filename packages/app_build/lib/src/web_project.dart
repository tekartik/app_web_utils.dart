import 'package:fs_shim/utils/path.dart';
import 'package:tekartik_app_web_build/app_build.dart';

/// Use WebAppBuilder instead
class WebProject {
  /// The path
  late final String path;

  /// windows/posix path ok
  WebProject(String path,
      {
      /// Default to empty
      List<String>? flavors,
      String? buildPlatform,
      String? androidModule,
      String? buildType}) {
    this.path = toNativePath(path);
  }

  /// Default to web
  Future<void> build({String? folder}) async {
    await webdevBuild(path, folder: folder);
  }
}
