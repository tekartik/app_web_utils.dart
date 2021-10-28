import 'package:dev_test/package.dart';
import 'package:path/path.dart';

Future main() async {
  for (var dir in [
    'web_splash',
    'app_build',
    'sw_build',
    'sw_utils',
  ]) {
    await packageRunCi(join('..', 'packages', dir));
  }
}
