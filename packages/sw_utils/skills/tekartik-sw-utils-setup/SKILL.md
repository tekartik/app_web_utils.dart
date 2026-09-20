---
name: tekartik-sw-utils-setup
description: >-
  Use when registering the service worker of a Dart web app from the page with
  tekartik_sw_utils: appInitServiceWorker() to register sw.js defensively at
  startup, optionNoServiceWorker (the ?no-sw url argument, ArgumentsOption) to
  disable it while developing, and when to fall back to package:service_worker
  window.dart (register, isSupported, ready, onMessage) for a custom script
  name or scope.
---

# Registering a service worker from the page (tekartik_sw_utils)

`tekartik_sw_utils` is a two-symbol convenience package for the window side of
a Dart web app: one call that registers `sw.js` if the browser supports it and
the url does not ask to skip it. Browser only.

## Guidelines

* Git dependency (not on pub.dev); it pulls `service_worker` and
  `tekartik_browser_utils`:
  ```yaml
  dependencies:
    tekartik_sw_utils:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/sw_utils
      version: '>=0.1.0'
  ```
* Import `package:tekartik_sw_utils/sw_utils.dart`. It exports exactly
  `appInitServiceWorker()` and `optionNoServiceWorker`. It reads
  `window.location`, so it only runs in the browser (`web/main.dart` of a
  webdev app, or a `@TestOn('browser')` test), never on the VM.
* `await appInitServiceWorker()` from `main()`: it checks
  `optionNoServiceWorker`, then `service_worker`'s `isSupported`, then
  `register('sw.js')` with a 500 ms timeout. It never throws and never returns
  a registration: every outcome (disabled, unsupported, registered, error) is
  just printed to the console. Treat it as fire-and-forget app startup.
* Because of that timeout, a completed `appInitServiceWorker()` does not mean
  the worker is active. When you need the active worker (to `postMessage` it),
  `await sw.ready` from `package:service_worker/window.dart` afterwards.
* The script name `sw.js` and the default `/` scope are hardcoded. For another
  file name (a Dart worker compiled to `sw.dart.js`), another scope, or to
  handle errors, call `register(...)` from
  `package:service_worker/window.dart` yourself instead.
* `optionNoServiceWorker` is an `ArgumentsOption('no-sw')` from
  `package:tekartik_browser_utils/arguments_option.dart`, parsed from the
  query string: `has()` returns `true` for `?no-sw`, `false` for `?no-no-sw`,
  `null` when neither is present. Loading the app with `?no-sw` is the
  supported way to bypass a stale cached worker while developing. Reuse the
  same object if the rest of the app needs to know.
* An already installed worker keeps controlling the page even with `?no-sw`:
  that flag only skips the registration call. Unregister with
  `getRegistrations()` (or devtools) when you need a clean state.
* Generate the `sw.js` this registers with the sibling package
  `tekartik_sw_build` (`generateServiceWorker`) and make sure the file is
  listed in the app `deploy.yaml`, at the site root so its scope covers the
  whole app.

## Examples

### Register at startup

```dart
import 'package:tekartik_sw_utils/sw_utils.dart';

Future<void> main() async {
  await appInitServiceWorker();
  // ...build the ui
}
```

### Register, then talk to the active worker

```dart
import 'package:service_worker/window.dart' as sw;
import 'package:tekartik_sw_utils/sw_utils.dart';

Future<void> main() async {
  await appInitServiceWorker();
  if (sw.isNotSupported || (optionNoServiceWorker.has() ?? false)) {
    return;
  }
  var registration = await sw.ready;
  sw.onMessage.listen((event) {
    print('from worker: ${event.data}');
  });
  registration.active?.postMessage('hello');
}
```

### Branch on the no-sw url argument

```dart
import 'package:tekartik_sw_utils/sw_utils.dart';

Future<void> main() async {
  // http://localhost:8080/?no-sw -> true, ?no-no-sw -> false, else null
  var disabled = optionNoServiceWorker.has() ?? false;
  if (disabled) {
    print('service worker disabled by url argument');
  } else {
    await appInitServiceWorker();
  }
}
```

### Custom script name and scope

```dart
import 'package:service_worker/window.dart' as sw;
import 'package:tekartik_sw_utils/sw_utils.dart';

/// appInitServiceWorker only knows about 'sw.js' at the root.
Future<sw.ServiceWorkerRegistration?> registerDartWorker() async {
  if ((optionNoServiceWorker.has() ?? false) || sw.isNotSupported) {
    return null;
  }
  try {
    return await sw.register(
      'sw.dart.js',
      sw.ServiceWorkerRegisterOptions(scope: '/'),
    );
  } catch (e) {
    print('service worker error $e');
    return null;
  }
}
```
