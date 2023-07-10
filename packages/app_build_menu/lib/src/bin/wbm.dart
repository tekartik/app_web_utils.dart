import 'dart:io';

import 'package:args/args.dart';
import 'package:tekartik_app_web_build_menu/app_build_menu.dart';

Future<void> main(List<String> arguments) async {
  wbm(arguments);
}

/// Node build menu
void wbm(List<String> arguments) {
  var parser = ArgParser();
  parser.addOption('source-dir', abbr: 's', defaultsTo: 'web');
  parser.addOption('web-port', abbr: 'p');

  var result = parser.parse(arguments);
  var srcDir = result['source-dir'] as String;
  var webPort = int.tryParse((result['web-port'] as String?) ?? '');

  var appPath = result.rest;

  if (appPath.isEmpty) {
    appPath = [Directory.current.path];
  }
  mainMenu(appPath.sublist(1), () {
    menuWebAppContent(
        options: WebAppOptions(
            packageTop: appPath.first, srcDir: srcDir, webPort: webPort));
    menuAppContent(path: appPath.first);
  });
}
