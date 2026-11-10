---
name: tekartik-sw-utils-setup
description: >-
  Use when registering the service worker of a Dart web app from the page with
  tekartik_sw_utils: appInitServiceWorker() to register sw.js defensively at
  startup, optionNoServiceWorker (the ?no-sw url argument, ArgumentsOption) to
  disable it while developing, and when to call
  window.navigator.serviceWorker of package:web (register, ready, onmessage)
  yourself for a custom script name or scope. Works with dart2js and
  dart2wasm.
---

# Registering a service worker from the page (tekartik_sw_utils)

`tekartik_sw_utils` is a two-symbol convenience package for the window side of
a Dart web app: one call that registers `sw.js` if the browser supports it and
the url does not ask to skip it. Browser only, on `package:web` and
`dart:js_interop`: dart2js and dart2wasm (`--wasm`) builds.

## Guidelines

* Git dependency (not on pub.dev); it pulls `web` and
  `tekartik_browser_utils`:
  ```yaml
  dependencies:
    tekartik_sw_utils:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/sw_utils
  ```
* Import `package:tekartik_sw_utils/sw_utils.dart`. It exports exactly
  `appInitServiceWorker()` and `optionNoServiceWorker`. It reads
  `window.location`, so it only runs in the browser (`web/main.dart` of a
  webdev app, or a `@TestOn('browser')` test), never on the VM. Until
  2026-11 it used `package:service_worker` (`dart:html`) and did not build
  with dart2wasm; it is on `package:web` now.
* `await appInitServiceWorker()` from `main()`: it checks
  `optionNoServiceWorker`, then whether `navigator.serviceWorker` exists (it
  does not on an insecure http page), then
  `navigator.serviceWorker.register('sw.js')` with a 500 ms timeout. It never throws and never returns
  a registration: every outcome (disabled, unsupported, registered, error) is
  just printed to the console. Treat it as fire-and-forget app startup.
* Because of that timeout, a completed `appInitServiceWorker()` does not mean
  the worker is active. When you need the active worker (to `postMessage` it),
  `await web.window.navigator.serviceWorker.ready.toDart` afterwards.
* The script name `sw.js` is hardcoded and resolved against the page url;
  without a scope option its scope is the folder of the script (`/` for a
  page at the site root, `/app/` for `/app/index.html`). For another
  file name (a Dart worker compiled to `sw.dart.js`), another scope, or to
  handle errors, call `web.window.navigator.serviceWorker.register(...)`
  (`package:web`) yourself instead.
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
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_sw_utils/sw_utils.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  await appInitServiceWorker();
  var navigator = web.window.navigator;
  if (!(navigator as JSObject).has('serviceWorker') ||
      (optionNoServiceWorker.has() ?? false)) {
    return;
  }
  var container = navigator.serviceWorker;
  var registration = await container.ready.toDart;
  container.onmessage = (web.MessageEvent event) {
    print('from worker: ${event.data.dartify()}');
  }.toJS;
  registration.active?.postMessage('hello'.toJS);
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
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:tekartik_sw_utils/sw_utils.dart';
import 'package:web/web.dart' as web;

/// appInitServiceWorker only knows about 'sw.js' next to the page.
Future<web.ServiceWorkerRegistration?> registerDartWorker() async {
  var navigator = web.window.navigator;
  if ((optionNoServiceWorker.has() ?? false) ||
      !(navigator as JSObject).has('serviceWorker')) {
    return null;
  }
  try {
    return await navigator.serviceWorker
        .register('sw.dart.js'.toJS, web.RegistrationOptions(scope: '/'))
        .toDart;
  } catch (e) {
    print('service worker error $e');
    return null;
  }
}
```
