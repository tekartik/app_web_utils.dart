---
name: tekartik-web-splash-setup
description: >-
  Use when adding or hiding the loading splash screen of a Dart or Flutter web
  app with tekartik_web_splash: webSplashHide() and webSplashReady() from
  package:tekartik_web_splash/web_splash.dart, the required
  <div id="app_splash" class="app-loading"> markup and its opacity transition
  css, and the ?splash / ?splash=5000 url parameter used to freeze or delay the
  splash while developing.
---

# Web app splash screen (tekartik_web_splash)

`tekartik_web_splash` hides the html splash screen of a web app once the app is
loaded: the page shows a `<div id="app_splash" class="app-loading">` while the
compiled JavaScript boots, and the app calls `webSplashHide()` when it is ready.
Two functions, no state to manage; off the web (vm) both are no-ops, so the call
can live in shared code.

## Guidelines

* Git dependency:
  ```yaml
  dependencies:
    tekartik_web_splash:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/web_splash
      version: '>=0.1.0'
  ```
  Its only dependency is `package:web`, so it works in a plain Dart (webdev)
  web app as well as in a Flutter web app.
* Import `package:tekartik_web_splash/web_splash.dart`. It exports exactly
  `webSplashHide()` and `webSplashReady()`. The implementation is selected by
  conditional import: on the vm both are empty functions, nothing throws.
* Markup: put the splash element last in `<body>` so it covers everything, with
  the `app-loading` class set:
  ```html
  <body>
    <div id="output"></div>
    <!-- last, above everything else -->
    <div id="app_splash" class="app-loading"></div>
  </body>
  ```
  The id `app_splash` and the class `app-loading` are hardcoded in the package;
  the element is looked up the first time `webSplashHide()` is called, so it
  must already be in the DOM by then.
* Css: style `#app_splash` as a full-screen overlay with `opacity: 0` and an
  opacity `transition`, and `#app_splash.app-loading { opacity: 1 }`.
  `webSplashHide()` only removes the class; the fade out is your transition,
  and the element removes itself from the DOM on `transitionend` (without a
  transition it stays there, invisible).
* `webSplashReady()` captures `Uri.base` early. Call it at the very top of
  `main()`, before anything can change the url (a router, the Flutter engine),
  otherwise the `?splash` parameter is read from the already-rewritten url.
  It does nothing else, in particular it does not show the splash.
* `webSplashHide()` is idempotent and safe to call several times (e.g. once
  after the first data load and once from an error handler).
* Development helpers, read from the start url: `?splash` keeps the splash
  visible forever (inspect its css), `?splash=5000` hides it after 5000 ms,
  `?splash=0` hides it on the next event loop turn. With no `splash`
  parameter, hiding is immediate.
* Compatibility: the old versions set `app-loading` on `<body>`; `hide()` still
  removes that class from the body, so the previous markup keeps working.
* Do not import `package:tekartik_web_splash/src/splash_web.dart` (the internal
  `Splash` class with its `appSplashId` / `appLoadingClass` parameters): it is
  not exported and it breaks the vm build. A different id or class means doing
  the `classList.remove` yourself with `package:web`.
* Tests touching the splash need `@TestOn('browser')` and must insert the
  `#app_splash` element before calling `webSplashHide()`; the package
  `dart_test.yaml` runs `vm` and `chrome`.

## Examples

### Plain Dart web app entry point

```dart
import 'package:tekartik_web_splash/web_splash.dart';
import 'package:web/web.dart' as web;

Future<void> main() async {
  webSplashReady(); // first, before the url can change
  await _loadApp();
  webSplashHide();
}

Future<void> _loadApp() async {
  await Future<void>.delayed(const Duration(milliseconds: 500));
  web.document.body!.querySelector('#output')!.textContent = 'loaded';
}
```

### Hiding the splash even on failure

```dart
import 'package:tekartik_web_splash/web_splash.dart';

Future<void> main() async {
  webSplashReady();
  try {
    await _initApp();
  } catch (e) {
    _showError('$e');
  } finally {
    webSplashHide(); // idempotent
  }
}

Future<void> _initApp() async {}

void _showError(String message) {}
```

### Shared entry point, splash only on the web

```dart
// Compiles and runs on the vm too: both calls are no-ops there.
import 'package:tekartik_web_splash/web_splash.dart';

Future<void> appMain(Future<void> Function() init) async {
  webSplashReady();
  await init();
  webSplashHide();
}
```

### Browser test

```dart
@TestOn('browser')
library;

import 'package:tekartik_web_splash/web_splash.dart';
import 'package:test/test.dart';
import 'package:web/web.dart' as web;

void main() {
  test('hide removes the app-loading class', () {
    var element = web.HTMLDivElement()
      ..id = 'app_splash'
      ..className = 'app-loading';
    web.document.body!.appendChild(element);
    webSplashHide();
    expect(element.className, '');
  });
}
```

## Common mistakes

* No `app-loading` class on the `#app_splash` div: nothing is ever shown, and
  `webSplashHide()` has nothing to remove.
* Calling `webSplashHide()` before the splash element is in the DOM (in a
  `<script>` that runs in `<head>` without `defer`, or before the div).
* Expecting the element to disappear without an opacity transition: the removal
  is driven by the `transitionend` event.
* Leaving `?splash` in the url and reporting the app as stuck on the splash.
* Calling `webSplashReady()` after the router rewrote the url, which loses the
  `?splash` parameter.
