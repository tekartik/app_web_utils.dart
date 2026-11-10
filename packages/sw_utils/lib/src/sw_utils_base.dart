// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_browser_utils/arguments_option.dart';
import 'package:web/web.dart' as web;

/// True when the browser exposes `navigator.serviceWorker` (not on an
/// insecure http page).
bool get _isServiceWorkerSupported =>
    (web.window.navigator as JSObject).has('serviceWorker');

/// Registers `sw.js` (relative to the page) when service workers are
/// supported and the url does not hold `?no-sw`, waiting at most 500 ms.
/// Never throws: the outcome is printed.
Future appInitServiceWorker() async {
  if (optionNoServiceWorker.has() ?? false) {
    print('No service worker');
  } else {
    try {
      if (_isServiceWorkerSupported) {
        await web.window.navigator.serviceWorker
            .register('sw.js'.toJS)
            .toDart
            .timeout(const Duration(milliseconds: 500));
        print('ServiceWorker registered.');
      } else {
        print('ServiceWorkers are not supported.');
      }
    } catch (e) {
      print('Service worker error $e');
    }
  }
}

/// The `no-sw` url argument: `has()` is true for `?no-sw`, false for
/// `?no-no-sw`, null otherwise.
var optionNoServiceWorker = ArgumentsOption('no-sw');
