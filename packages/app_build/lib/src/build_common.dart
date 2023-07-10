const webAppDeployDirDefault = 'deploy';
const webAppSrcDirDefault = 'web';
const webAppPortDefault = 8060;

/// Node app common options.
class WebAppOptions {
  /// App packages (default to '.')
  late final String packageTop;

  /// Typically 'deploy' for a single node app
  late final String deployDir;

  /// Typically 'bin' to 'node', default to 'bin'
  late final String srcDir;

  /// Web port, default dynamic.
  final int? webPort;

  WebAppOptions(
      {String? packageTop, String? deployDir, String? srcDir, this.webPort}) {
    this.packageTop = packageTop ?? '.';
    this.deployDir = deployDir ?? webAppDeployDirDefault;
    this.srcDir = srcDir ?? webAppSrcDirDefault;
  }
}
