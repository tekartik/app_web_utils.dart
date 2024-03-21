import 'package:dev_build/build_support.dart';
import 'package:dev_build/menu/menu_io.dart';
import 'package:dev_build/package.dart';
import 'package:path/path.dart';

Future main(List<String> arguments) async {
  mainMenuConsole(arguments, menuAppContent);
}

void menuAppContent({String path = '.'}) {
  Map pubspec;
  var checkPubspec = () async {
    try {
      pubspec = await pathGetPubspecYamlMap(path);
      return pubspec;
    } catch (_) {}
    return <String, Object?>{};
  }();

  menu('pub', () async {
    enter(() async {
      write('App path: ${absolute(path)}');
      var pubspec = await checkPubspec;
      write('Package: ${pubspec['name']}');
    });

    item('list sub projects', () async {
      await recursivePackagesRun([path], action: (path) {
        write('project: ${absolute(path)}');
      });
    });

    item('run_ci', () async {
      await packageRunCi(path);
    });

    item('pub_get', () async {
      await packageRunCi(path, options: PackageRunCiOptions(pubGetOnly: true));
    });
    item('pub_upgrade', () async {
      await packageRunCi(path,
          options: PackageRunCiOptions(pubUpgradeOnly: true));
    });
  });
}
