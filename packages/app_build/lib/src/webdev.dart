import 'package:dev_build/build_support.dart';
import 'package:process_run/shell.dart';

import 'import.dart';

final _webdevReadyLock = Lock();
var _webdevReady = false;

/// Check and activate webdev
Future<void> webdevReady({bool verbose = false, bool force = false}) async {
  if (!_webdevReady || force) {
    if (verbose) {
      print('webdevReady(force: $force)');
    }
    await _webdevReadyLock.synchronized(() async {
      if (!_webdevReady) {
        // Set alias
        shellEnvironment =
            ShellEnvironment()
              ..aliases['webdev'] = 'dart pub global run webdev';
      }
      await checkAndActivateWebdev();
      _webdevReady = true;
      await run('webdev --version', verbose: verbose);
    });
  }
}
