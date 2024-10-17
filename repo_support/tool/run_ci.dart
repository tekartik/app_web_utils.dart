// ignore_for_file: depend_on_referenced_packages

import 'package:dev_build/package.dart';

Future main() async {
  await packageRunCi('..', options: PackageRunCiOptions(recursive: true));
}
