import 'package:process_run/shell.dart';

import 'import.dart';

final _webdevReadyLock = Lock();
var _webdevReady = false;
Future<void> webdevReady({bool verbose = false, bool force = false}) async {
  if (!_webdevReady || force) {
    if (verbose) {
      print('webdevReady(force: $force)');
    }
    await _webdevReadyLock.synchronized(() async {
      if (_webdevReady || force) {
        // Set alias
        shellEnvironment = ShellEnvironment()
          ..aliases['webdev'] = 'dart pub global run webdev';
      }
      try {
        // Exists?
        await run('webdev --version', verbose: verbose);
      } catch (e) {
        await checkAndActivatePackage('webdev');
        await run('webdev --version', verbose: verbose);
      }
    });
  }
}
