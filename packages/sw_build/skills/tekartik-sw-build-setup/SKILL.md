---
name: tekartik-sw-build-setup
description: >-
  Use when generating the sw.js service worker of a Dart web app build with
  tekartik_sw_build: generateServiceWorker(resources, coreBundle) to produce
  the flutter-style caching worker javascript, generateWebAppServiceWorker to
  dump the md5 hash of every built file, building the resource url -> md5 map,
  the CORE app shell list, and wiring it in a tool/ build script next to
  tekartik_app_web_build and tekartik_sw_utils.
---

# Service worker generation (tekartik_sw_build)

`tekartik_sw_build` generates the JavaScript of a caching service worker for a
built web app: a port of the worker the Flutter web tool emits, with a
`RESOURCES` map of url to content hash so that a byte change automatically
invalidates the browser cache. It is a `dart:io` build-time helper, meant for
`tool/` scripts, never for browser code.

## Guidelines

* Git dependency (not on pub.dev), usually a `dev_dependencies` entry of the
  web app:
  ```yaml
  dev_dependencies:
    tekartik_sw_build:
      git:
        url: https://github.com/tekartik/app_web_utils.dart
        path: packages/sw_build
      version: '>=0.1.0'
  ```
* Import `package:tekartik_sw_build/sw_build.dart`; it exports exactly two
  functions, `generateServiceWorker` and `generateWebAppServiceWorker`.
  `package:tekartik_sw_build/src/...` (`swPackageBuild`, `generateMd5`) is
  internal, do not import it.
* `generateServiceWorker(Map<String, String> resources, List<String>
  coreBundle)` returns the worker source as a `String`; writing it (normally
  `<build>/sw.js`) is up to you.
  - `resources` maps a url relative to the site root to a revision string,
    in practice the md5 of the file content (`md5.convert(bytes).toString()`
    from `package:crypto/crypto.dart`).
  - Name the entry for `index.html` `'/'`: the generated `fetch` handler
    rewrites the origin root, `/#...` urls and the empty key to `'/'` and
    serves it online-first, so an `index.html` key alone never matches.
  - `coreBundle` is the app shell fetched during `install`; every entry must
    also be a key of `resources` (typically `'/'`, `'main.dart.js'`, plus the
    css and manifest files).
  - Do not put `sw.js` itself in `resources`.
* What the generated worker does: `skipWaiting()` on install, fills a `TEMP`
  cache with `CORE`, then on activate moves it to `flutter-app-cache`, diffs
  the previous `tekartik-app-manifest` manifest and drops only the resources
  whose hash changed. It answers `postMessage('skipWaiting')` and
  `postMessage('downloadOffline')`. Non-`GET` requests and urls missing from
  `RESOURCES` fall through to the network.
* Cache invalidation is implicit: regenerate `sw.js` at every build; a changed
  hash changes the worker bytes, which makes the browser install the new one.
* `generateWebAppServiceWorker(String dir)` is a diagnostic helper: it walks
  `dir` recursively and writes `<md5> <file>` lines to stdout. It does **not**
  write an `sw.js`; build the map yourself and call `generateServiceWorker`.
* Where it fits: build the app with `tekartik_app_web_build` (`webdevBuild` /
  `WebAppBuilder`), generate `sw.js` into the build output before
  `buildToDeploy`, and add `sw.js` to the app `deploy.yaml` file list.
  Register the worker from the page with `tekartik_sw_utils`'s
  `appInitServiceWorker()`.
* A Dart-written worker is a separate entry point (`web/sw.dart` compiled by
  `build_web_compilers` to `sw.dart.js`) and is unrelated to this generated
  `sw.js`: pick one, or register the Dart one explicitly.

## Examples

### Generate sw.js for a build folder

```dart
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:tekartik_sw_build/sw_build.dart';

/// Writes <buildDir>/sw.js caching every file of the build.
Future<void> generateSw(String buildDir) async {
  var resources = <String, String>{};
  for (var entity in Directory(buildDir).listSync(recursive: true)) {
    if (entity is File) {
      // Always a posix url, whatever the host platform separator is.
      var url = posix.joinAll(split(relative(entity.path, from: buildDir)));
      if (url == 'sw.js') {
        continue;
      }
      if (url == 'index.html') {
        url = '/'; // the fetch handler maps the origin root to '/'
      }
      resources[url] = md5.convert(entity.readAsBytesSync()).toString();
    }
  }
  var coreBundle = [
    '/',
    'main.dart.js',
    'styles.css',
    'manifest.json',
  ].where(resources.containsKey).toList();
  await File(
    join(buildDir, 'sw.js'),
  ).writeAsString(generateServiceWorker(resources, coreBundle));
  stdout.writeln('generated sw.js with ${resources.length} resources');
}

Future<void> main() async {
  await generateSw(join('build', 'web'));
}
```

### Build, generate the worker, copy to deploy

```dart
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:tekartik_app_web_build/app_build.dart';
import 'package:tekartik_sw_build/sw_build.dart';

Future<void> main() async {
  var dir = '.';
  await webdevBuild(dir);
  var buildDir = join(dir, 'build', 'web');
  var index = File(join(buildDir, 'index.html'));
  var main = File(join(buildDir, 'main.dart.js'));
  var resources = {
    '/': md5.convert(index.readAsBytesSync()).toString(),
    'main.dart.js': md5.convert(main.readAsBytesSync()).toString(),
  };
  await File(
    join(buildDir, 'sw.js'),
  ).writeAsString(generateServiceWorker(resources, ['/', 'main.dart.js']));
  await buildToDeploy(dir); // deploy.yaml must list sw.js
}
```

### List the hashes of a built app

```dart
import 'package:tekartik_sw_build/sw_build.dart';

Future<void> main() async {
  // Prints '<md5> <file>' for every file below build/web.
  await generateWebAppServiceWorker('build/web');
}
```
