import 'package:process_run/shell.dart';

import 'import.dart';

final _dhttpdReadyLock = Lock();
var _dhttpdReady = false;

/// dhttpd simple server (testing only-
Future<void> dhttpdReady({bool verbose = false, bool force = false}) async {
  if (!_dhttpdReady || force) {
    if (verbose) {
      print('dhttpd(force: $force)');
    }

    await _dhttpdReadyLock.synchronized(() async {
      if (!_dhttpdReady) {
        // Set alias
        shellEnvironment =
            ShellEnvironment()
              ..aliases['dhttpd'] = 'dart pub global run dhttpd';
      }
      await _checkAndActivateDhttp(force: force, verbose: verbose);
      _dhttpdReady = true;
    });
  }
}

Future<void> _checkAndActivateDhttp({
  bool force = false,
  bool verbose = false,
}) async {
  if (force) {
    await _activateDhttp(verbose: verbose);
  } else {
    try {
      await run('dhttpd --help', verbose: verbose);
    } catch (e) {
      await _activateDhttp(verbose: verbose);
    }
  }
}

Future<void> _activateDhttp({bool verbose = false}) async {
  await run('dart pub global activate dhttpd', verbose: verbose);
}
