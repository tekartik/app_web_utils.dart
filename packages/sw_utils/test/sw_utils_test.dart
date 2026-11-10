@TestOn('browser')
library;

import 'dart:js_interop';

import 'package:tekartik_sw_utils/sw_utils.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

/// The registrations whose script is test/sw.js.
Future<List<web.ServiceWorkerRegistration>> _testRegistrations() async {
  var registrations =
      (await web.window.navigator.serviceWorker.getRegistrations().toDart)
          .toDart;
  return registrations.where((registration) {
    var worker =
        registration.installing ?? registration.waiting ?? registration.active;
    return worker?.scriptURL.endsWith('/sw.js') ?? false;
  }).toList();
}

void main() {
  group('sw_utils', () {
    test('appInitServiceWorker registers sw.js', () async {
      // The test page is served by localhost (a secure context) next to
      // test/sw.js.
      expect(optionNoServiceWorker.has(), isNull);
      await appInitServiceWorker();
      // The registration may take more than the 500 ms waited.
      var registrations = <web.ServiceWorkerRegistration>[];
      for (var i = 0; i < 100 && registrations.isEmpty; i++) {
        registrations = await _testRegistrations();
        if (registrations.isEmpty) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        }
      }
      try {
        expect(registrations, hasLength(1));
        expect(web.window.location.href, startsWith(registrations.first.scope));
      } finally {
        for (var registration in registrations) {
          await registration.unregister().toDart;
        }
      }
    }, timeout: const Timeout(Duration(seconds: 30)));
  });
}
